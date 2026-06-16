"""
Script autonome de génération d'activité journalière ERP + Marketplace + CRM.

Ce fichier reprend le simulateur journalier dans une version copiable dans
un autre projet. Il reste volontairement dépendant de PostgreSQL, asyncpg et
Faker, mais n'importe pas le reste de l'application.

Variables d'environnement requises :
  DATABASE_ERP_URL_PG   postgresql://user:pass@localhost:5433/pc_erp
  DATABASE_MKT_URL_PG   postgresql://user:pass@localhost:5434/pc_marketplace
  DATABASE_CRM_URL_PG   postgresql://user:pass@localhost:5436/pc_crm  (optionnel)

Usage:
  python daily_activity_isolated.py
  python daily_activity_isolated.py --scale 3.0
  python daily_activity_isolated.py --date 2026-05-23
  python daily_activity_isolated.py --dry-run
  python daily_activity_isolated.py --force
  python daily_activity_isolated.py --days 7
"""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import random
import string
import sys
import uuid
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone
from typing import Any

import asyncpg
from faker import Faker


if sys.stdout.encoding and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if sys.stderr.encoding and sys.stderr.encoding.lower() != "utf-8":
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s — %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("daily_activity")


fake = Faker("fr_FR")
_faker_seed_env = os.getenv("FAKER_SEED")
if _faker_seed_env is not None:
    Faker.seed(int(_faker_seed_env))
    random.seed(int(_faker_seed_env))
    logger.info("Faker initialisé avec graine fixe FAKER_SEED=%s", _faker_seed_env)
else:
    logger.info("Faker initialisé avec graine aléatoire (production)")


_ERP_DSN = os.getenv("DATABASE_ERP_URL_PG")
_MKT_DSN = os.getenv("DATABASE_MKT_URL_PG")
_CRM_DSN = os.getenv("DATABASE_CRM_URL_PG")

if not _ERP_DSN:
    raise EnvironmentError(
        "La variable d'environnement DATABASE_ERP_URL_PG est manquante. "
        "Exemple : postgresql://user:password@localhost:5433/pc_erp"
    )
if not _MKT_DSN:
    raise EnvironmentError(
        "La variable d'environnement DATABASE_MKT_URL_PG est manquante. "
        "Exemple : postgresql://user:password@localhost:5434/pc_marketplace"
    )

ERP_DSN: str = _ERP_DSN
MKT_DSN: str = _MKT_DSN
CRM_DSN: str | None = _CRM_DSN


@dataclass
class DailyConfig:
    scale: float = 1.0
    sim_date: date = field(default_factory=date.today)
    dry_run: bool = False
    force: bool = False

    @property
    def new_customers(self) -> int:
        return max(1, int(250 * self.scale * self._day_factor))

    @property
    def new_orders(self) -> int:
        return max(1, int(400 * self.scale * self._day_factor))

    @property
    def pipeline_batch(self) -> int:
        return max(10, int(2_000 * self.scale))

    @property
    def new_reviews(self) -> int:
        return max(1, int(80 * self.scale * self._day_factor))

    @property
    def new_tickets(self) -> int:
        return max(1, int(30 * self.scale * self._day_factor))

    @property
    def new_work_orders(self) -> int:
        return max(1, int(15 * self.scale * self._day_factor))

    @property
    def stock_movements(self) -> int:
        return max(10, int(200 * self.scale))

    @property
    def crm_activities(self) -> int:
        return max(5, int(30 * self.scale * self._day_factor))

    @property
    def _day_factor(self) -> float:
        dow = self.sim_date.weekday()
        month = self.sim_date.month
        day_f = 1.0 if dow < 5 else (0.7 if dow == 5 else 0.5)
        month_f = 1.6 if month in (11, 12) else 1.0
        return day_f * month_f


def uid() -> str:
    return str(uuid.uuid4())


def ts(h: int = 0, m: int = 0, sim_date: date | None = None) -> datetime:
    d = sim_date or date.today()
    return datetime(
        d.year, d.month, d.day,
        h or random.randint(7, 22),
        m or random.randint(0, 59),
        tzinfo=timezone.utc,
    )


def today_ts(sim_date: date) -> datetime:
    return ts(sim_date=sim_date)


def short_ref(prefix: str, sim_date: date) -> str:
    suffix = "".join(random.choices(string.ascii_uppercase + string.digits, k=5))
    return f"{prefix}-{sim_date.strftime('%Y%m%d')}-{suffix}"


class DailyActivitySimulator:
    def __init__(self, cfg: DailyConfig):
        self.cfg = cfg
        self.d = cfg.sim_date
        self._products: list[dict[str, Any]] = []
        self._customers: list[str] = []
        self._payment_methods: list[str] = []
        self._carriers: list[str] = []
        self._pc_models: list[str] = []
        self._employees: list[str] = []
        self._components: list[str] = []
        self._locations: list[str] = []
        self._warehouses: list[str] = []
        self._crm_sales_reps: list[str] = []
        self._crm_accounts: list[str] = []
        self.stats: dict[str, int] = {}

    async def _load_mkt_refs(self, conn) -> None:
        rows = await conn.fetch(
            "SELECT p.id, p.name, p.sku, pp.price_ttc FROM shared.products p "
            "JOIN marketplace.product_prices pp ON pp.product_id = p.id "
            "LIMIT 2000"
        )
        self._products = [
            {"id": str(r["id"]), "name": r["name"], "sku": r["sku"], "price": float(r["price_ttc"])}
            for r in rows
        ]

        self._customers = [
            str(r["id"]) for r in await conn.fetch(
                "SELECT id FROM marketplace.customers WHERE deleted_at IS NULL ORDER BY RANDOM() LIMIT 5000"
            )
        ]
        self._payment_methods = [str(r["id"]) for r in await conn.fetch("SELECT id FROM marketplace.payment_methods")]
        self._carriers = [str(r["id"]) for r in await conn.fetch("SELECT id FROM marketplace.carriers")]

    async def _load_erp_refs(self, conn) -> None:
        self._pc_models = [str(r["id"]) for r in await conn.fetch("SELECT id FROM erp.pc_models")]
        self._employees = [str(r["id"]) for r in await conn.fetch("SELECT id FROM erp.employees WHERE deleted_at IS NULL")]
        self._components = [str(r["id"]) for r in await conn.fetch("SELECT id FROM erp.components LIMIT 500")]
        self._locations = [str(r["id"]) for r in await conn.fetch("SELECT id FROM erp.warehouse_locations")]
        self._warehouses = [str(r["id"]) for r in await conn.fetch("SELECT id FROM shared.warehouses")]

    async def _already_ran(self, conn) -> bool:
        row = await conn.fetchrow(
            "SELECT COUNT(*) AS n FROM marketplace.orders WHERE ordered_at::date = $1",
            self.d,
        )
        return row["n"] > 0

    async def _new_customers(self, conn) -> int:
        n = self.cfg.new_customers
        if self.cfg.dry_run:
            return n

        created = 0
        for _ in range(n):
            first = fake.first_name()
            last = fake.last_name()
            domain = fake.free_email_domain()
            email = f"{first.lower()}.{last.lower()}.{fake.bothify('###')}@{domain}"
            user_id = uid()
            cust_id = uid()
            created_at = today_ts(self.d)

            try:
                async with conn.transaction():
                    await conn.execute(
                        """INSERT INTO auth.users
                           (id, email, password_hash, role, is_active, email_verified, created_at)
                           VALUES ($1, $2, $3, 'customer', true, true, $4)
                           ON CONFLICT (email) DO NOTHING""",
                        user_id, email, fake.sha256()[:60], created_at,
                    )
                    await conn.execute(
                        """INSERT INTO marketplace.customers
                           (id, user_id, first_name, last_name, phone, birthdate, created_at)
                           VALUES ($1, $2, $3, $4, $5, $6, $7)
                           ON CONFLICT (user_id) DO NOTHING""",
                        cust_id, user_id, first, last, fake.phone_number()[:30],
                        fake.date_of_birth(minimum_age=18, maximum_age=75), created_at,
                    )
                    await conn.execute(
                        """INSERT INTO marketplace.customer_addresses
                           (id, customer_id, label, first_name, last_name,
                            street, city, postal_code, country_code, is_default, created_at)
                           VALUES (gen_random_uuid(), $1, 'Domicile', $2, $3, $4, $5, $6, 'FR', true, $7)
                           ON CONFLICT DO NOTHING""",
                        cust_id, first, last, fake.street_address()[:255], fake.city()[:100], fake.postcode()[:10], created_at,
                    )
                    await conn.execute(
                        """INSERT INTO marketplace.loyalty_points
                           (id, customer_id, balance, updated_at)
                           VALUES (gen_random_uuid(), $1, 0, $2)
                           ON CONFLICT (customer_id) DO NOTHING""",
                        cust_id, created_at,
                    )
                created += 1
            except asyncpg.UniqueViolationError:
                logger.debug("Doublon e-mail ignoré pour %s", email)
            except asyncpg.PostgresError as exc:
                logger.warning("Erreur PostgreSQL lors de la création du client %s : %s", email, exc)

        new_ids = await conn.fetch(
            "SELECT id FROM marketplace.customers WHERE created_at::date = $1 LIMIT 1000",
            self.d,
        )
        self._customers = list(set(self._customers + [str(r["id"]) for r in new_ids]))
        return created

    async def _new_orders(self, conn) -> int:
        if not self._products or not self._customers:
            return 0
        n = self.cfg.new_orders
        if self.cfg.dry_run:
            return n

        order_rows, line_rows, status_rows = [], [], []
        for _ in range(n):
            cust_id = random.choice(self._customers)
            n_lines = random.randint(1, 4)
            prods = random.sample(self._products, min(n_lines, len(self._products)))
            order_id = uid()
            ordered_at = today_ts(self.d)
            reference = short_ref("ORD", self.d)

            subtotal = sum(round(p["price"] * random.randint(1, 2), 4) for p in prods)
            shipping = 0.0 if subtotal >= 99 else 5.99
            discount = round(subtotal * random.choice([0.0, 0.0, 0.0, 0.05, 0.10]), 4)
            total = round(subtotal + shipping - discount, 4)
            addr = json.dumps({"street": fake.street_address(), "city": fake.city(), "postal_code": fake.postcode(), "country": "FR"})

            order_rows.append((
                order_id, cust_id, reference, "pending",
                round(subtotal, 4), round(shipping, 4), discount, max(total, 0),
                "EUR", addr, addr, ordered_at, ordered_at,
            ))

            for p in prods:
                qty = random.randint(1, 2)
                price_ht = round(p["price"] / 1.2, 4)
                line_rows.append((
                    order_id, p["id"], p["name"][:255], p["sku"][:64],
                    qty, price_ht, round(p["price"], 4), 0.2, round(p["price"] * qty, 4), ordered_at,
                ))

            status_rows.append((order_id, "pending", today_ts(self.d)))

        if order_rows:
            await conn.executemany(
                """INSERT INTO marketplace.orders
                   (id, customer_id, reference, status,
                    subtotal_ttc, shipping_ttc, discount_ttc, total_ttc,
                    currency, shipping_address, billing_address,
                    ordered_at, updated_at)
                   VALUES ($1,$2::uuid,$3,$4,$5,$6,$7,$8,$9,$10::jsonb,$11::jsonb,$12,$13)
                   ON CONFLICT (reference) DO NOTHING""",
                order_rows,
            )
            # Ne garder que les order_ids réellement insérés pour éviter les FK violations
            inserted_ids = {
                str(r["id"]) for r in await conn.fetch(
                    "SELECT id FROM marketplace.orders WHERE id = ANY($1::uuid[])",
                    [r[0] for r in order_rows],
                )
            }
            line_rows    = [r for r in line_rows    if r[0] in inserted_ids]
            status_rows  = [r for r in status_rows  if r[0] in inserted_ids]

            if line_rows:
                await conn.executemany(
                    """INSERT INTO marketplace.order_lines
                       (id, order_id, product_id, product_name, product_sku,
                        quantity, unit_price_ht, unit_price_ttc, vat_rate, total_ttc, created_at)
                       VALUES (gen_random_uuid(),$1::uuid,$2::uuid,$3,$4,$5,$6,$7,$8,$9,$10)
                       ON CONFLICT DO NOTHING""",
                    line_rows,
                )
            if status_rows:
                await conn.executemany(
                    """INSERT INTO marketplace.order_status_history
                       (id, order_id, status, comment, changed_at)
                       VALUES (gen_random_uuid(),$1::uuid,$2,NULL,$3)
                       ON CONFLICT DO NOTHING""",
                    status_rows,
                )

        return len(inserted_ids) if order_rows else 0

    async def _advance_order_pipeline(self, conn) -> dict[str, int]:
        if self.cfg.dry_run:
            return {}

        now = datetime.now(timezone.utc)
        counts: dict[str, int] = {}
        limit = self.cfg.pipeline_batch
        transitions = [
            ("pending", "confirmed", timedelta(hours=1), limit),
            ("confirmed", "processing", timedelta(hours=4), limit),
            ("processing", "shipped", timedelta(hours=24), limit),
            ("shipped", "delivered", timedelta(hours=48), limit),
        ]

        for from_s, to_s, min_age, lim in transitions:
            cutoff = now - min_age
            rows = await conn.fetch(
                """SELECT id FROM marketplace.orders
                   WHERE status = $1 AND updated_at <= $2
                   ORDER BY updated_at LIMIT $3
                   FOR UPDATE SKIP LOCKED""",
                from_s, cutoff, lim,
            )
            if not rows:
                counts[f"{from_s}→{to_s}"] = 0
                continue

            ids = [r["id"] for r in rows]
            ts_now = now
            await conn.execute(
                f"""UPDATE marketplace.orders
                    SET status = '{to_s}', updated_at = $1
                    WHERE id = ANY($2::uuid[])""",
                ts_now, ids,
            )
            hist_rows = [(str(oid), to_s, ts_now) for oid in ids]
            await conn.executemany(
                """INSERT INTO marketplace.order_status_history
                   (id, order_id, status, comment, changed_at)
                   VALUES (gen_random_uuid(), $1::uuid, $2, NULL, $3)
                   ON CONFLICT DO NOTHING""",
                hist_rows,
            )
            counts[f"{from_s}→{to_s}"] = len(ids)

        return counts

    async def _process_payments(self, conn) -> int:
        if self.cfg.dry_run:
            return 0

        rows = await conn.fetch(
            """SELECT o.id, o.total_ttc
               FROM marketplace.orders o
               WHERE o.status IN ('confirmed','processing','shipped','delivered')
                 AND o.updated_at::date = $1
                 AND NOT EXISTS (SELECT 1 FROM marketplace.payments p WHERE p.order_id = o.id)
               LIMIT 2000""",
            self.d,
        )
        if not rows:
            return 0

        pm_id = random.choice(self._payment_methods) if self._payment_methods else None
        pay_rows = []
        for r in rows:
            pay_rows.append((uid(), str(r["id"]), pm_id, float(r["total_ttc"]), "EUR", "completed", fake.md5()[:60], today_ts(self.d), today_ts(self.d)))

        await conn.executemany(
            """INSERT INTO marketplace.payments
               (id, order_id, payment_method_id, amount, currency,
                status, gateway_ref, paid_at, created_at)
               VALUES ($1,$2::uuid,$3::uuid,$4,$5,$6,$7,$8,$9)
               ON CONFLICT DO NOTHING""",
            pay_rows,
        )
        return len(pay_rows)

    async def _generate_invoices(self, conn) -> int:
        if self.cfg.dry_run:
            return 0

        rows = await conn.fetch(
            """SELECT DISTINCT o.id, o.total_ttc
               FROM marketplace.orders o
               JOIN marketplace.payments p ON p.order_id = o.id
               WHERE p.paid_at::date = $1
                 AND NOT EXISTS (SELECT 1 FROM marketplace.invoices i WHERE i.order_id = o.id)
               LIMIT 2000""",
            self.d,
        )
        if not rows:
            return 0

        rows_to_insert = []
        ts_now = today_ts(self.d)
        for r in rows:
            num = f"FAC-{self.d.strftime('%Y%m%d')}-{uid()[:8].upper()}"
            rows_to_insert.append((uid(), str(r["id"]), num, float(r["total_ttc"]), None, ts_now, ts_now + timedelta(days=30)))

        await conn.executemany(
            """INSERT INTO marketplace.invoices
               (id, order_id, number, total_ttc, pdf_url, issued_at, due_at)
               VALUES ($1,$2::uuid,$3,$4,$5,$6,$7)
               ON CONFLICT (number) DO NOTHING""",
            rows_to_insert,
        )
        return len(rows_to_insert)

    async def _create_shipments(self, conn) -> int:
        if self.cfg.dry_run or not self._carriers:
            return 0

        rows = await conn.fetch(
            """SELECT id FROM marketplace.orders
               WHERE status = 'shipped' AND updated_at::date = $1
                 AND NOT EXISTS (SELECT 1 FROM marketplace.shipments s WHERE s.order_id = orders.id)
               LIMIT 2000""",
            self.d,
        )
        if not rows:
            return 0

        ship_rows = []
        ts_now = today_ts(self.d)
        for r in rows:
            carrier = random.choice(self._carriers)
            tracking = fake.bothify("??################").upper()
            ship_rows.append((uid(), str(r["id"]), carrier, tracking, "in_transit", ts_now, None, ts_now))

        await conn.executemany(
            """INSERT INTO marketplace.shipments
               (id, order_id, carrier_id, tracking_number,
                status, shipped_at, delivered_at, created_at)
               VALUES ($1,$2::uuid,$3::uuid,$4,$5,$6,$7,$8)
               ON CONFLICT DO NOTHING""",
            ship_rows,
        )
        return len(ship_rows)

    async def _update_shipments_delivered(self, conn) -> int:
        if self.cfg.dry_run:
            return 0

        ts_now = today_ts(self.d)
        result = await conn.execute(
            """UPDATE marketplace.shipments sh
               SET status = 'delivered', delivered_at = $1
               FROM marketplace.orders o
               WHERE o.id = sh.order_id
                 AND o.status = 'delivered'
                 AND o.updated_at::date = $2
                 AND sh.status != 'delivered'""",
            ts_now, self.d,
        )
        return int(result.split()[-1]) if result else 0

    async def _new_reviews(self, conn) -> int:
        if self.cfg.dry_run:
            return 0

        n = self.cfg.new_reviews
        cutoff_from = self.d - timedelta(days=14)
        cutoff_to = self.d - timedelta(days=3)
        rows = await conn.fetch(
            """SELECT DISTINCT ol.product_id, o.customer_id, ol.id AS line_id
               FROM marketplace.orders o
               JOIN marketplace.order_lines ol ON ol.order_id = o.id
               WHERE o.status = 'delivered'
                 AND o.updated_at::date BETWEEN $1 AND $2
                 AND NOT EXISTS (
                     SELECT 1 FROM marketplace.reviews r
                     WHERE r.customer_id = o.customer_id
                       AND r.order_line_id = ol.id
                 )
               LIMIT $3""",
            cutoff_from, cutoff_to, n,
        )
        if not rows:
            return 0

        ratings = [5, 5, 5, 4, 4, 4, 3, 3, 2, 1]
        titles = {
            5: ["Parfait !", "Excellent produit", "Je recommande vivement", "Top qualité"],
            4: ["Très bien", "Bon rapport qualité/prix", "Satisfait", "Produit conforme"],
            3: ["Correct", "Sans plus", "Peut mieux faire", "Dans la moyenne"],
            2: ["Décevant", "Pas à la hauteur", "Quelques défauts", "Bof"],
            1: ["À éviter", "Très déçu", "Produit défectueux", "Ne pas acheter"],
        }

        review_rows = []
        ts_now = today_ts(self.d)
        for r in rows:
            rating = random.choice(ratings)
            title = random.choice(titles[rating])
            review_rows.append((uid(), str(r["product_id"]), str(r["customer_id"]), str(r["line_id"]), rating, title[:128], fake.paragraph(nb_sentences=random.randint(2, 4)), True, ts_now))

        await conn.executemany(
            """INSERT INTO marketplace.reviews
               (id, product_id, customer_id, order_line_id,
                rating, title, body, is_verified, created_at)
               VALUES ($1,$2::uuid,$3::uuid,$4::uuid,$5,$6,$7,$8,$9)
               ON CONFLICT DO NOTHING""",
            review_rows,
        )
        return len(review_rows)

    async def _new_support_tickets(self, conn) -> int:
        if self.cfg.dry_run or not self._customers:
            return 0

        n = self.cfg.new_tickets
        subjects = [
            "Commande non reçue après 10 jours",
            "Produit endommagé à la livraison",
            "Demande de retour sous 14 jours",
            "Erreur dans ma facture",
            "Produit incompatible avec mon matériel",
            "Suivi colis introuvable",
            "Demande de remboursement",
            "Problème d'installation du produit",
            "Pièce manquante dans le colis",
            "Question sur la garantie",
            "PC qui ne démarre pas",
            "Performances inférieures aux annonces",
        ]
        priorities = ["low", "low", "medium", "medium", "medium", "high"]
        order_rows = await conn.fetch(
            """SELECT id, customer_id FROM marketplace.orders
               WHERE status IN ('delivered','shipped')
                 AND updated_at::date BETWEEN $1 AND $2
               ORDER BY RANDOM() LIMIT $3""",
            self.d - timedelta(days=7), self.d, n,
        )

        ticket_rows = []
        msg_rows = []
        ts_now = today_ts(self.d)
        for i in range(n):
            ticket_id = uid()
            cust_id = random.choice(self._customers)
            order_id = str(order_rows[i % len(order_rows)]["id"]) if order_rows else None
            ticket_rows.append((ticket_id, cust_id, order_id, random.choice(subjects), "open", random.choice(priorities), ts_now))
            msg_rows.append((uid(), ticket_id, f"client:{cust_id[:8]}", fake.paragraph(nb_sentences=3), ts_now + timedelta(minutes=random.randint(1, 10))))

        await conn.executemany(
            """INSERT INTO marketplace.support_tickets
               (id, customer_id, order_id, subject, status, priority, created_at)
               VALUES ($1,$2::uuid,$3::uuid,$4,$5,$6,$7)
               ON CONFLICT DO NOTHING""",
            ticket_rows,
        )
        await conn.executemany(
            """INSERT INTO marketplace.support_messages
               (id, ticket_id, sender, body, sent_at)
               VALUES ($1,$2::uuid,$3,$4,$5)
               ON CONFLICT DO NOTHING""",
            msg_rows,
        )
        return len(ticket_rows)

    async def _award_loyalty_points(self, conn) -> int:
        if self.cfg.dry_run:
            return 0

        rows = await conn.fetch(
            """SELECT o.id, o.customer_id, o.total_ttc
               FROM marketplace.orders o
               WHERE o.status = 'delivered'
                 AND o.updated_at::date = $1
                 AND NOT EXISTS (
                     SELECT 1 FROM marketplace.loyalty_transactions lt
                     WHERE lt.reference = 'ORDER-' || o.id::text
                 )
               LIMIT 3000""",
            self.d,
        )
        if not rows:
            return 0

        ts_now = today_ts(self.d)
        lt_rows = []
        for r in rows:
            pts = max(1, int(float(r["total_ttc"])))
            lt_rows.append((uid(), str(r["customer_id"]), pts, "earn", f"ORDER-{r['id']}", ts_now))

        await conn.executemany(
            """INSERT INTO marketplace.loyalty_transactions
               (id, customer_id, points, type, reference, created_at)
               VALUES ($1,$2::uuid,$3,$4,$5,$6)
               ON CONFLICT DO NOTHING""",
            lt_rows,
        )
        for r in rows:
            pts = max(1, int(float(r["total_ttc"])))
            await conn.execute(
                """UPDATE marketplace.loyalty_points
                   SET balance = balance + $1, updated_at = NOW()
                   WHERE customer_id = $2::uuid""",
                pts, str(r["customer_id"]),
            )
        return len(lt_rows)

    async def _new_work_orders(self, conn) -> int:
        if self.cfg.dry_run or not self._pc_models:
            return 0

        n = self.cfg.new_work_orders
        rows = []
        ts_now = today_ts(self.d)
        for _ in range(n):
            model_id = random.choice(self._pc_models)
            rows.append((uid(), model_id, short_ref("OF", self.d), random.randint(1, 10), "planned", self.d + timedelta(days=random.randint(1, 5)), ts_now, ts_now))

        await conn.executemany(
            """INSERT INTO erp.work_orders
               (id, pc_model_id, reference, quantity, status,
                planned_at, created_at, updated_at)
               VALUES ($1,$2::uuid,$3,$4,$5,$6,$7,$8)
               ON CONFLICT (reference) DO NOTHING""",
            rows,
        )
        return len(rows)

    async def _advance_production(self, conn) -> dict[str, int]:
        if self.cfg.dry_run:
            return {}

        counts = {}
        ts_now = today_ts(self.d)
        transitions = [
            ("planned", "in_progress", timedelta(hours=8), 50),
            ("in_progress", "qc", timedelta(hours=24), 40),
            ("qc", "completed", timedelta(hours=4), 30),
        ]
        for from_s, to_s, min_age, lim in transitions:
            cutoff = datetime.now(timezone.utc) - min_age
            rows = await conn.fetch(
                """SELECT id FROM erp.work_orders
                   WHERE status = $1 AND updated_at <= $2
                   ORDER BY updated_at LIMIT $3
                   FOR UPDATE SKIP LOCKED""",
                from_s, cutoff, lim,
            )
            if not rows:
                counts[f"{from_s}→{to_s}"] = 0
                continue
            ids = [r["id"] for r in rows]
            completed_at = ts_now if to_s == "completed" else None
            await conn.execute(
                f"""UPDATE erp.work_orders
                    SET status='{to_s}', updated_at=$1,
                        started_at = CASE WHEN status='planned' THEN $1 ELSE started_at END,
                        completed_at = $2
                    WHERE id = ANY($3::uuid[])""",
                ts_now, completed_at, ids,
            )
            counts[f"{from_s}→{to_s}"] = len(ids)
        return counts

    async def _daily_timesheets(self, conn) -> int:
        if self.cfg.dry_run or not self._employees:
            return 0
        if self.d.weekday() >= 5:
            return 0

        week_start = self.d - timedelta(days=self.d.weekday())
        work_types = ["production", "production", "production", "admin", "meeting"]
        inserted = 0
        for emp_id in self._employees:
            ts_row = await conn.fetchrow(
                """SELECT id FROM erp.timesheets
                   WHERE employee_id = $1 AND week_start = $2""",
                emp_id, week_start,
            )
            if ts_row is None:
                ts_id = uid()
                await conn.execute(
                    """INSERT INTO erp.timesheets
                       (id, employee_id, week_start, status, total_hours, created_at)
                       VALUES ($1,$2::uuid,$3,'open',0,$4)
                       ON CONFLICT DO NOTHING""",
                    ts_id, emp_id, week_start, today_ts(self.d),
                )
            else:
                ts_id = str(ts_row["id"])

            hours = round(random.uniform(7.0, 9.0), 2)
            work_type = random.choice(work_types)
            try:
                await conn.execute(
                    """INSERT INTO erp.timesheet_lines
                       (id, timesheet_id, day, hours, type)
                       VALUES (gen_random_uuid(),$1::uuid,$2,$3,$4)
                       ON CONFLICT DO NOTHING""",
                    ts_id, self.d, hours, work_type,
                )
                await conn.execute(
                    """UPDATE erp.timesheets
                       SET total_hours = total_hours + $1
                       WHERE id = $2::uuid""",
                    hours, ts_id,
                )
                inserted += 1
            except asyncpg.UniqueViolationError:
                logger.debug("Doublon timesheet_line ignoré (employé %s, jour %s)", emp_id, self.d)
            except asyncpg.PostgresError as exc:
                logger.warning("Erreur pointage employé %s le %s : %s", emp_id, self.d, exc)
        return inserted

    async def _stock_movements_daily(self, conn) -> int:
        if self.cfg.dry_run or not self._components or not self._locations:
            return 0

        n = self.cfg.stock_movements
        ts_now = today_ts(self.d)
        types = ["sortie", "sortie", "sortie", "entree", "ajustement"]
        rows = []
        for _ in range(n):
            mvt_type = random.choice(types)
            qty = random.randint(1, 20) if mvt_type != "sortie" else -random.randint(1, 10)
            rows.append((uid(), random.choice(self._components), random.choice(self._locations), mvt_type, qty, short_ref("MVT", self.d), ts_now))

        await conn.executemany(
            """INSERT INTO erp.component_stock_movements
               (id, component_id, location_id, type, quantity, reference, moved_at)
               VALUES ($1,$2::uuid,$3::uuid,$4,$5,$6,$7)
               ON CONFLICT DO NOTHING""",
            rows,
        )
        return len(rows)

    # ── CRM ───────────────────────────────────────────────────────────────────

    async def _load_crm_refs(self, conn) -> None:
        self._crm_sales_reps = [
            str(r["id"]) for r in await conn.fetch(
                "SELECT id FROM crm.sales_reps WHERE is_active = true"
            )
        ]
        self._crm_accounts = [
            str(r["id"]) for r in await conn.fetch(
                "SELECT id FROM crm.accounts WHERE deleted_at IS NULL ORDER BY RANDOM() LIMIT 3000"
            )
        ]

    async def _sync_new_customers_to_crm(self, crm_conn, mkt_conn) -> int:
        """Crée les comptes + contacts CRM pour les nouveaux clients marketplace du jour."""
        new_rows = await mkt_conn.fetch("""
            SELECT c.id AS customer_id, c.first_name, c.last_name, c.phone,
                   u.email, a.city, a.country_code
            FROM marketplace.customers c
            JOIN auth.users u ON u.id = c.user_id
            LEFT JOIN LATERAL (
                SELECT city, country_code FROM marketplace.customer_addresses
                WHERE customer_id = c.id AND deleted_at IS NULL
                ORDER BY is_default DESC, created_at ASC LIMIT 1
            ) a ON TRUE
            WHERE c.created_at::date = $1 AND c.deleted_at IS NULL
        """, self.d)

        if not new_rows or not self._crm_sales_reps:
            return 0

        count = 0
        for row in new_rows:
            acc_id     = uid()
            contact_id = uid()
            owner_id   = random.choice(self._crm_sales_reps)
            ext_ref    = f"CRM-CUST-{str(row['customer_id'])[:8].upper()}"

            inserted = await crm_conn.fetchval("""
                INSERT INTO crm.accounts (
                    id, external_ref, account_type, source_customer_id,
                    name, email, phone, city, country_code,
                    segment, status, total_orders, lifetime_value, loyalty_balance, owner_id
                ) VALUES ($1,$2,'customer',$3,$4,$5,$6,$7,$8,'prospect','new',0,0,0,$9)
                ON CONFLICT (source_customer_id) DO NOTHING
                RETURNING id
            """, acc_id, ext_ref, row["customer_id"],
                f"{row['first_name']} {row['last_name']}",
                row["email"], row["phone"],
                row["city"], row["country_code"] or "FR", owner_id)

            if inserted:
                await crm_conn.execute("""
                    INSERT INTO crm.contacts (
                        id, account_id, first_name, last_name,
                        email, phone, role, source_customer_id, is_primary
                    ) VALUES ($1,$2,$3,$4,$5,$6,'Acheteur',$7,true)
                    ON CONFLICT DO NOTHING
                """, contact_id, acc_id,
                    row["first_name"], row["last_name"],
                    row["email"], row["phone"], row["customer_id"])
                count += 1

        return count

    async def _update_crm_account_stats(self, crm_conn, mkt_conn) -> int:
        """Met à jour lifetime_value, total_orders, segment pour les comptes ayant eu des commandes aujourd'hui."""
        rows = await mkt_conn.fetch("""
            SELECT c.id AS customer_id,
                   COUNT(*) FILTER (WHERE o.status <> 'cancelled') AS order_count,
                   COALESCE(SUM(o.total_ttc) FILTER (WHERE o.status <> 'cancelled'), 0) AS lifetime_value,
                   MAX(o.ordered_at) FILTER (WHERE o.status <> 'cancelled') AS last_order_at,
                   COALESCE(lp.balance, 0) AS loyalty_balance
            FROM marketplace.customers c
            JOIN marketplace.orders o ON o.customer_id = c.id
            LEFT JOIN marketplace.loyalty_points lp ON lp.customer_id = c.id
            WHERE o.updated_at::date = $1 AND c.deleted_at IS NULL
            GROUP BY c.id, lp.balance
        """, self.d)

        count = 0
        for row in rows:
            ltv    = float(row["lifetime_value"])
            orders = int(row["order_count"])
            segment = (
                "vip"     if ltv >= 2500 or orders >= 12 else
                "premium" if ltv >= 750  or orders >= 5  else
                "active"  if orders >= 1 else
                "prospect"
            )
            result = await crm_conn.execute("""
                UPDATE crm.accounts
                SET total_orders    = $2,
                    lifetime_value  = $3,
                    last_order_at   = $4,
                    loyalty_balance = $5,
                    segment         = $6,
                    status          = 'active',
                    updated_at      = NOW()
                WHERE source_customer_id = $1 AND deleted_at IS NULL
            """, row["customer_id"], orders, ltv,
                row["last_order_at"], int(row["loyalty_balance"]), segment)
            if result != "UPDATE 0":
                count += 1

        return count

    async def _gen_crm_activities(self, crm_conn) -> int:
        """Génère des activités journalières (calls, emails, meetings, notes) pour les commerciaux."""
        if not self._crm_accounts or not self._crm_sales_reps:
            return 0

        n      = self.cfg.crm_activities
        sample = random.sample(self._crm_accounts, min(n, len(self._crm_accounts)))

        _act_weights = [("call", 4), ("email", 4), ("meeting", 2), ("note", 1)]
        _act_types   = [t for t, _ in _act_weights]
        _weights     = [w for _, w in _act_weights]
        _directions  = {"call": ["outbound", "outbound", "inbound"], "email": ["outbound", "outbound", "inbound"]}
        _subjects    = {
            "call":    ["Suivi commande récente", "Présentation nouveau catalogue", "Relance devis", "Point satisfaction client"],
            "email":   ["Offre exclusive", "Devis personnalisé", "Confirmation de commande", "Proposition commerciale"],
            "meeting": ["Réunion découverte", "Présentation offre", "Négociation contrat", "Bilan partenariat"],
            "note":    ["Note interne", "Remarque client", "Observation terrain", "Compte-rendu appel"],
        }
        _outcomes = {
            "call":    ["reached", "no_answer", "left_voicemail"],
            "email":   ["replied", "no_reply", "sent"],
            "meeting": ["positive", "neutral", "negative"],
            "note":    [None],
        }
        _durations = {"call": (5, 45), "meeting": (30, 120)}

        rows = []
        ts_now = today_ts(self.d)
        for acc_id in sample:
            act_type  = random.choices(_act_types, weights=_weights, k=1)[0]
            direction = random.choice(_directions[act_type]) if act_type in _directions else None
            outcome   = random.choice(_outcomes[act_type])
            dur_range = _durations.get(act_type)
            duration  = random.randint(*dur_range) if dur_range else None
            rows.append((
                uid(), acc_id, None, None, random.choice(self._crm_sales_reps),
                act_type, direction, random.choice(_subjects[act_type]),
                None, outcome, duration, ts_now,
            ))

        await crm_conn.executemany("""
            INSERT INTO crm.activities
                (id, account_id, contact_id, opportunity_id, owner_id,
                 activity_type, direction, subject, body, outcome, duration_minutes, occurred_at)
            VALUES ($1,$2::uuid,$3,$4,$5::uuid,$6,$7,$8,$9,$10,$11,$12)
            ON CONFLICT DO NOTHING
        """, rows)

        return len(rows)

    async def _advance_crm_opportunities(self, crm_conn) -> dict[str, int]:
        """Fait avancer quelques opportunités dans le pipeline et enregistre les pipeline_events."""
        if not self._crm_sales_reps:
            return {}

        ts_now  = today_ts(self.d)
        counts: dict[str, int] = {}
        transitions = [
            ("qualified",   "proposal",    0.15),
            ("proposal",    "negotiation", 0.10),
            ("negotiation", "won",         0.08),
        ]

        for from_s, to_s, rate in transitions:
            limit = max(1, round(20 * rate * self.cfg.scale))
            rows  = await crm_conn.fetch("""
                SELECT id FROM crm.opportunities
                WHERE stage = $1 AND status = 'open'
                ORDER BY RANDOM() LIMIT $2
            """, from_s, limit)

            if not rows:
                counts[f"{from_s}→{to_s}"] = 0
                continue

            ids = [r["id"] for r in rows]
            for opp_id in ids:
                await crm_conn.execute("""
                    UPDATE crm.opportunities
                    SET stage = $2, updated_at = NOW()
                    WHERE id = $1
                """, opp_id, to_s)
                await crm_conn.execute("""
                    INSERT INTO crm.pipeline_events
                        (id, opportunity_id, stage_from, stage_to, owner_id, occurred_at)
                    VALUES ($1,$2,$3,$4,$5,$6)
                    ON CONFLICT DO NOTHING
                """, uid(), opp_id, from_s, to_s, random.choice(self._crm_sales_reps), ts_now)

            counts[f"{from_s}→{to_s}"] = len(ids)

        return counts

    def _print_stat(self, label: str, value: int) -> None:
        icon = "🟢" if value > 0 else "⚪"
        print(f"  {icon}  {label:<38} {value:>6}")
        self.stats[label] = value

    async def run(self) -> dict[str, Any]:
        self.stats = {}
        day_str = self.d.isoformat()
        dry_label = " [DRY-RUN]" if self.cfg.dry_run else ""

        print(f"\n{'═'*60}")
        print(f"  ACTIVITÉ JOURNALIÈRE{dry_label} — {day_str}")
        print(f"  Scale={self.cfg.scale:.1f}  |  {self.cfg._day_factor:.1f}× (saisonnalité)")
        print(f"{'═'*60}")

        print("\n  🛒  MARKETPLACE")
        mkt_conn = await asyncpg.connect(MKT_DSN)
        try:
            if not self.cfg.force and not self.cfg.dry_run and await self._already_ran(mkt_conn):
                print(f"  ⚠️  Des commandes existent déjà pour le {day_str}.")
                print("     Utilisez --force pour forcer l'exécution.")
                return {"skipped": True, "date": day_str}

            await self._load_mkt_refs(mkt_conn)
            self._print_stat("Nouveaux clients", await self._new_customers(mkt_conn))
            self._print_stat("Nouvelles commandes", await self._new_orders(mkt_conn))
            pipeline = await self._advance_order_pipeline(mkt_conn)
            for k, v in pipeline.items():
                self._print_stat(f"Pipeline {k}", v)
            self.stats["pipeline"] = pipeline
            self._print_stat("Paiements traités", await self._process_payments(mkt_conn))
            self._print_stat("Factures générées", await self._generate_invoices(mkt_conn))
            self._print_stat("Expéditions créées", await self._create_shipments(mkt_conn))
            self._print_stat("Expéditions livrées", await self._update_shipments_delivered(mkt_conn))
            self._print_stat("Nouveaux avis", await self._new_reviews(mkt_conn))
            self._print_stat("Tickets SAV ouverts", await self._new_support_tickets(mkt_conn))
            self._print_stat("Points fidélité attribués", await self._award_loyalty_points(mkt_conn))
        finally:
            await mkt_conn.close()

        print("\n  🔧  ERP")
        erp_conn = await asyncpg.connect(ERP_DSN)
        try:
            await self._load_erp_refs(erp_conn)
            self._print_stat("Nouveaux ordres de fab.", await self._new_work_orders(erp_conn))
            prod = await self._advance_production(erp_conn)
            for k, v in prod.items():
                self._print_stat(f"Production {k}", v)
            self.stats["production"] = prod
            self._print_stat("Pointages saisis", await self._daily_timesheets(erp_conn))
            self._print_stat("Mouvements de stock", await self._stock_movements_daily(erp_conn))
        finally:
            await erp_conn.close()

        if CRM_DSN:
            print("\n  🤝  CRM")
            crm_conn = await asyncpg.connect(CRM_DSN)
            mkt_conn2 = await asyncpg.connect(MKT_DSN)
            try:
                await self._load_crm_refs(crm_conn)
                self._print_stat("Nouveaux comptes CRM",    await self._sync_new_customers_to_crm(crm_conn, mkt_conn2))
                self._print_stat("Stats comptes mis à jour", await self._update_crm_account_stats(crm_conn, mkt_conn2))
                self._print_stat("Activités CRM générées",  await self._gen_crm_activities(crm_conn))
                pipeline_crm = await self._advance_crm_opportunities(crm_conn)
                for k, v in pipeline_crm.items():
                    self._print_stat(f"Pipeline CRM {k}", v)
                self.stats["pipeline_crm"] = pipeline_crm
            finally:
                await crm_conn.close()
                await mkt_conn2.close()
        else:
            logger.info("DATABASE_CRM_URL_PG non défini — section CRM ignorée")

        print(f"\n{'═'*60}")
        print(f"  ✅  Journée {day_str} simulée avec succès")
        print(f"{'═'*60}\n")
        return self.stats


def parse_args():
    parser = argparse.ArgumentParser(
        description="Simulateur d'activité journalière ERP + Marketplace + CRM",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemples :
  python daily_activity_isolated.py                       # aujourd'hui, scale=1
  python daily_activity_isolated.py --scale 3.0           # Black Friday (x3)
  python daily_activity_isolated.py --date 2026-05-23     # rejouer une date
  python daily_activity_isolated.py --dry-run             # preview sans écriture
  python daily_activity_isolated.py --force               # forcer même si déjà exécuté
  python daily_activity_isolated.py --days 7              # simuler les 7 derniers jours
        """,
    )
    parser.add_argument("--scale", type=float, default=1.0, help="Multiplicateur de volume (défaut 1.0)")
    parser.add_argument("--date", type=str, default=None, help="Date de début ISO-8601 (défaut: aujourd'hui)")
    parser.add_argument("--days", type=int, default=1, help="Nombre de jours consécutifs à simuler (défaut 1)")
    parser.add_argument("--dry-run", action="store_true", help="Calculer sans insérer")
    parser.add_argument("--force", action="store_true", help="Forcer même si la journée a déjà été simulée")
    return parser.parse_args()


async def main() -> None:
    args = parse_args()
    if args.date:
        start_date = date.fromisoformat(args.date)
    else:
        start_date = date.today() - timedelta(days=args.days - 1)

    base_scale = args.scale
    for i in range(args.days):
        sim_date = start_date + timedelta(days=i)
        if sim_date.month == 11:
            seasonal = 1.0 + (sim_date.day / 30) * 2.0
        elif sim_date.month == 12 and sim_date.day <= 24:
            seasonal = 2.5
        else:
            seasonal = 1.0

        cfg = DailyConfig(
            scale=round(base_scale * seasonal, 2),
            sim_date=sim_date,
            dry_run=args.dry_run,
            force=args.force,
        )
        sim = DailyActivitySimulator(cfg)
        result = await sim.run()
        if result.get("skipped"):
            print("  Arrêt de la boucle — journée déjà simulée.")
            break


if __name__ == "__main__":
    asyncio.run(main())