# The Meadows

Backyard short-game golf: six holes, one club, plenty of banter. This is the course guide, the scorecard and the all-time leaderboard in one app.

## What's in it

- **Guide** – the Invitational golf guide: welcome, the course (yards, par, map), one club, the four rules, etiquette and care, scoring.
- **Scorecard** – add up to 8 players, score hole by hole, pick a club for the round. The card on screen matches the printed Invitational card (yards, par, player rows, total). Tap any cell to jump to that hole.
- **Leaderboard** – every saved round ranks by score to par. Tap a row for the date, club and hole-by-hole scores.

Par 22 · 350 yards · Foam balls can still break windows.

## Files

| File | What it is |
| --- | --- |
| `index.html` | The whole app |
| `images/` | Logo and course map |
| `icons/`, `manifest.webmanifest` | iPhone home screen icon and app name |
| `supabase-setup.sql` | One-time database setup for the live leaderboard |
| `rounds.json` | Fallback shared leaderboard when no database is connected |

Keep `index.html`, `images/`, `icons/` and `manifest.webmanifest` together in the same folder.

## Publish on GitHub Pages

1. Create a **public** repository on GitHub (for example `the-meadows`).
2. Upload everything in this folder, including `images/` and `icons/`, and commit.
3. **Settings → Pages**: source **Deploy from a branch**, branch `main`, folder `/ (root)`, save.
4. The app is live at `https://<your-username>.github.io/the-meadows/`.

## Add to iPhone home screen

Open the live link in Safari, tap **Share**, then **Add to Home Screen**. Install it before playing: the home-screen app and Safari keep their own saved data.

## Live leaderboard (Supabase, free)

Without a database, rounds save on the phone that scored them. To make every phone show the same leaderboard:

1. Create a free project at supabase.com.
2. Open `supabase-setup.sql`, change `CHANGE-ME-PIN` to your admin PIN (6+ digits), and run it in **SQL Editor**.
3. Go to **Project Settings → API** and copy the **Project URL** and the **anon public** key.
4. In `index.html`, paste them into `SUPABASE_URL` and `SUPABASE_KEY` near the top of the script, and commit.

How it behaves:

- Saving a round uploads it right away. Everyone's leaderboard refreshes every 15 seconds while it's open.
- No signal? The round is kept on the phone and uploads when the connection returns.
- Anyone with the link can read and add rounds. **Deleting needs the admin PIN**, checked inside the database, not in the app.
- Free Supabase projects pause after a week of inactivity. If the leaderboard shows "Offline", open the project's dashboard and restore it. No data is lost.
- To change the PIN: `update admin_settings set pin_hash = extensions.crypt('NEW-PIN', extensions.gen_salt('bf')) where id = 1;`

The anon key is meant to be public, so it's safe in a public repo.

## Round format

```json
{
  "id": "m2x9k1ab3",
  "roundId": "m2x9k1aa7",
  "name": "Derek",
  "date": "2026-10-24",
  "club": "8-Iron",
  "scores": [4, 5, 4, 3, 3, 4],
  "par": 22,
  "toPar": 1
}
```

`roundId` groups everyone who played the same round together.
