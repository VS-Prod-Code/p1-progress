# p1-progress

Тимчасовий progress-дашборд для команди **P1 CRM** до дедлайну **2026-07-15**.

🔗 **Live:** https://vs-prod-code.github.io/p1-progress/

## Що це

Single-page dark UI, який показує:

- **Days to deadline** — головний показник, точний завжди (на основі календаря).
- **Schedule-health pill** — `On schedule / Slightly behind / Behind`. Евристика: % закритих issue vs % часу, що минув. Грубий сигнал (issues ≠ весь обсяг), tooltip показує обидва числа.
- **Time elapsed** — скільки часу минуло з початку проекту.
- **Momentum** — sparkline closed/open issue по зрізах із `history[]` (velocity + burndown). Рендериться при ≥2 точках.
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

### Автоматизована частина (issue counts + `updated`)

`update.ps1` тягне свіжі issue counts через `gh api` для labels у [VS-Prod-Code/p1_crm](https://github.com/VS-Prod-Code/p1_crm), переписує `evidence` у кожній фазі, ставить сьогоднішнє `updated` і **дописує агрегований зріз** `{date, closed, open}` у `history[]` (один запис на день — повторний запуск того ж дня перезаписує). Запуск під час Friday PM cadence:

```powershell
cd ~/Documents/!VAKULA_WORK/p1-progress
./update.ps1            # update + commit + push
./update.ps1 -DryRun    # тільки оновити файл, без git ops
```

Передумова: `gh` авторизований під твоїм акаунтом з доступом до приватного `VS-Prod-Code/p1_crm`.

### Ручна частина (status, дати)

Після `update.ps1` за потреби edit `data.json`:

- `phases[].status` — `planned | in-progress | done | tbd` (це **людська оцінка**, не похідна від issues).
- `start` / `deadline` / `phases[].start` / `phases[].end` — лише якщо план реально змінився.

Тоді просто `git commit -am "..." && git push`.

### Auto refresh via GitHub Actions

`.github/workflows/refresh-data.yml` має ручний тригер `workflow_dispatch` (кнопка **Run workflow** в Actions). Для cron щопʼятниці потрібен PAT secret:

1. [Створи fine-grained PAT](https://github.com/settings/personal-access-tokens/new) з доступом до `VS-Prod-Code/p1_crm` (Repository permissions → **Issues: Read**, **Metadata: Read**).
2. Додай secret у [Settings → Secrets and variables → Actions](https://github.com/VS-Prod-Code/p1-progress/settings/secrets/actions) під назвою `P1_CRM_READ_PAT`.
3. Розкоментуй `schedule:` блок у [`.github/workflows/refresh-data.yml`](.github/workflows/refresh-data.yml).

Cron: `0 19 * * 5` = пʼятниця 19:00 UTC = **22:00 EEST** (літо) / 21:00 EET (зима).

## Reference

Канонічна wiki проекту: `VS_code/wiki/projects/p1-crm.md` (internal vault).
