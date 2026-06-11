{% docs stg_crm__accounts %}
Comptes CRM — chaque enregistrement représente une entité commerciale (client, prospect, partenaire).

Colonnes métier notables :
- `account_type` : classification du compte (ex. `client`, `prospect`, `partner`).
- `status` / `segment` : état courant et positionnement marché.
- `lifetime_value` : revenu cumulé généré par le compte (pré-calculé côté source).
- `source_customer_id` / `source_supplier_code` : clés de jointure cross-domaine vers la Marketplace et l'ERP.
- `deleted_at` non NULL → compte supprimé logiquement (soft delete Airbyte CDC).
{% enddocs %}

{% docs stg_crm__contacts %}
Contacts CRM — personnes physiques rattachées à un compte.

Un compte peut avoir plusieurs contacts. Le flag `is_primary` identifie le contact principal.
Clés cross-domaine : `source_customer_id` (Marketplace) et `source_supplier_id` (ERP) permettent de réconcilier un contact avec son profil dans les autres sources.
{% enddocs %}

{% docs stg_crm__sales_reps %}
Commerciaux — membres de l'équipe de vente responsables des comptes et opportunités.

`territory` définit la zone géographique ou sectorielle assignée. `is_active = false` indique un commercial qui a quitté l'équipe (historique conservé pour les données passées).
{% enddocs %}

{% docs stg_crm__opportunities %}
Opportunités commerciales — une opportunité représente un deal potentiel associé à un compte.

Cycle de vie typique (champ `stage`) : `prospecting` → `qualification` → `proposal` → `negotiation` → `won` / `lost`.
- `probability` : pourcentage de chance de closing (0-100).
- `amount_estimated` : valeur prévisionnelle du deal.
- `source_order_id` : lorsque l'opportunité a abouti à une commande Marketplace, ce champ lie les deux systèmes.
{% enddocs %}

{% docs stg_crm__activities %}
Activités commerciales — toutes les interactions entre les commerciaux et les comptes/contacts.

Types courants (`activity_type`) : `call`, `email`, `meeting`, `demo`, `linkedin`.
- `direction` : `inbound` (initié par le prospect) ou `outbound` (initié par le commercial).
- `outcome` : résultat de l'interaction (ex. `interested`, `no_answer`, `objection`, `follow_up`).
- `duration_minutes` : pertinent pour les appels et réunions.
{% enddocs %}

{% docs stg_crm__pipeline_events %}
Événements de pipeline — historique de chaque changement d'étape d'une opportunité.

Chaque fois qu'une opportunité passe de `stage_from` à `stage_to`, un événement est enregistré.
Ce modèle permet de reconstruire la durée passée dans chaque étape et d'analyser la vélocité du pipeline de vente.
{% enddocs %}

{% docs stg_crm__tasks %}
Tâches commerciales — actions planifiées assignées à un commercial, rattachées à un compte ou une opportunité.

- `task_type` : nature de la tâche (ex. `call_back`, `send_proposal`, `follow_up`, `schedule_demo`).
- `priority` : `low`, `medium`, `high` — indique l'urgence.
- `due_at` / `completed_at` : permettent de mesurer le respect des délais.
{% enddocs %}
