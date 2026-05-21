# p1-progress

Тимчасовий progress-дашборд для команди **P1 CRM** до дедлайну **2026-07-15**.

🔗 **Live:** https://vs-prod-code.github.io/p1-progress/

## Що це

Single-page dark UI, який показує:

- **Days to deadline** — головний показник, точний завжди (на основі календаря).
- **Time elapsed** — скільки часу минуло з початку проекту.
- **Roadmap (Gantt)** — фази на часовій осі з маркером `TODAY`.
- **Phases** — статус кожної фази (`Planned / In Progress / Done / TBD`) + опис + дати + issues evidence.

## Що це **не**

- **Не частина продукту P1 CRM.** Це окремий внутрішній інструмент для команди.
- **Не джерело правди** для відсотка виконаних робіт. Issues — не вся робота; статуси фаз вписуються вручну.
- **Не довгостроковий artifact.** Видалиться або мігрує перед MVP.

## Стек

- Static HTML+CSS+JS (single file, no build, no deps).
- Дані у `data.json` — оновлюються вручну раз на тиждень під час Friday PM cadence.
- Хостинг: GitHub Pages з гілки `main`.

## Оновлення

Edit `data.json` → commit → push. GitHub Pages переденерує за 1-2 хв.

Поля, які треба оновлювати щотижня:

- `updated` — поточна дата (`YYYY-MM-DD`).
- `phases[].status` — `planned | in-progress | done | tbd`.
- `phases[].evidence.closed` / `.open` — числа issues по labels у [VS-Prod-Code/p1_crm](https://github.com/VS-Prod-Code/p1_crm).

`start` / `deadline` / `phases[].start` / `phases[].end` міняти лише якщо план реально змінився.

## Reference

Канонічна wiki проекту: `VS_code/wiki/projects/p1-crm.md` (internal vault).
