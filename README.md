# 🌙 Moonlight — Personalized Romantic Page Builder

A full-stack Next.js application where users create breathtaking, personalized romantic pages for someone special, featuring the original dreamy lilac cinematic aesthetic.

---

## ✦ Architecture Overview

```
moonlight-love/
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── page.tsx                  # Landing page (marketing)
│   │   ├── layout.tsx                # Root layout (fonts, globals)
│   │   ├── not-found.tsx             # 404 page
│   │   ├── globals.css               # Design system CSS variables & utilities
│   │   │
│   │   ├── auth/
│   │   │   ├── layout.tsx            # Shared auth shell
│   │   │   ├── login/page.tsx        # Sign in
│   │   │   ├── register/page.tsx     # Create account
│   │   │   └── callback/route.ts     # Supabase email confirmation handler
│   │   │
│   │   ├── dashboard/page.tsx        # User's page collection (server)
│   │   ├── create/page.tsx           # Multi-step wizard (client)
│   │   │
│   │   ├── p/[slug]/page.tsx         # PUBLIC romantic page (dynamic route)
│   │   ├── share/[slug]/page.tsx     # Post-creation share screen
│   │   │
│   │   └── api/
│   │       ├── pages/route.ts        # GET all / POST create
│   │       └── pages/[id]/route.ts   # PATCH update / DELETE
│   │
│   ├── components/
│   │   ├── romantic/                 # The cinematic experience layer
│   │   │   ├── RomanticPage.tsx      # Full page renderer (all 7 sections)
│   │   │   ├── ParticleCanvas.tsx    # Twinkling star particles
│   │   │   ├── FloatingPetals.tsx    # Falling lavender petals
│   │   │   ├── CustomCursor.tsx      # Lilac dot + ring cursor
│   │   │   └── HeartSVG.tsx          # Gradient heart icon
│   │   │
│   │   ├── editor/
│   │   │   ├── Steps.tsx             # All 7 wizard step components
│   │   │   ├── StepRecipient.tsx     # Re-export
│   │   │   ├── StepHero.tsx          # Re-export
│   │   │   ├── StepLetter.tsx        # Re-export
│   │   │   ├── StepReasons.tsx       # Re-export
│   │   │   ├── StepGallery.tsx       # Re-export
│   │   │   ├── StepSurprises.tsx     # Re-export
│   │   │   └── StepEnding.tsx        # Re-export
│   │   │
│   │   └── layout/
│   │       ├── DashboardClient.tsx   # Dashboard with page cards
│   │       └── SharePageClient.tsx   # URL + QR code share screen
│   │
│   ├── lib/
│   │   ├── supabase/
│   │   │   ├── client.ts             # Browser Supabase client
│   │   │   └── server.ts             # Server Supabase client (SSR)
│   │   ├── pages.ts                  # generateSlug, pageToContent, getPageUrl
│   │   └── defaults.ts               # Default content for new pages
│   │
│   ├── middleware.ts                 # Route protection + auth session refresh
│   └── types/index.ts                # TypeScript interfaces
│
├── supabase-schema.sql               # Complete DB schema (run once)
├── vercel.json                       # Deployment config
└── .env.local.example                # Environment variable template
```

---

## ✦ Database Schema

### `public.profiles`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | References auth.users |
| display_name | TEXT | User's name |
| created_at / updated_at | TIMESTAMPTZ | Auto-managed |

### `public.love_pages`
| Column | Type | Description |
|--------|------|-------------|
| id | UUID (PK) | Auto-generated |
| user_id | UUID | References auth.users |
| slug | TEXT (unique) | URL-safe, e.g. `moonlight-a3f7k` |
| recipient_name | TEXT | Shown throughout the page |
| intro_* | TEXT | Loading screen content |
| hero_* | TEXT | Hero section content |
| opening_* | TEXT | Opening quote + body |
| letter_* | TEXT / JSONB | Letter + paragraphs array |
| reasons_* | TEXT / JSONB | Title + items array |
| gallery_* | TEXT / JSONB | Photos array (url, caption, icon) |
| surprise_* | TEXT / JSONB | Cards array (icon, title, hint, reveal) |
| ending_* | TEXT | Closing section |
| music_url / music_label | TEXT | Optional background music |
| is_published | BOOLEAN | Visibility toggle |
| views | INTEGER | View counter |

### Storage Bucket: `love-photos`
Public bucket. Files stored as `{user_id}/{filename}`.

---

## ✦ Routing Structure

| Route | Access | Description |
|-------|--------|-------------|
| `/` | Public | Marketing landing page |
| `/auth/login` | Public (redirects if logged in) | Sign in |
| `/auth/register` | Public (redirects if logged in) | Create account |
| `/auth/callback` | Public | Email confirmation handler |
| `/dashboard` | Protected | User's page collection |
| `/create` | Protected | Multi-step page creation wizard |
| `/share/[slug]` | Protected (owner only) | URL + QR code share screen |
| `/p/[slug]` | Public | The romantic page (recipient view) |

---

## ✦ Setup Instructions

### 1. Clone and Install

```bash
git clone <your-repo>
cd moonlight-love
npm install
```

### 2. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Copy your **Project URL** and **Anon Key** from Settings → API
3. Run the entire contents of `supabase-schema.sql` in the SQL Editor

### 3. Configure Environment Variables

```bash
cp .env.local.example .env.local
```

Edit `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### 4. Configure Supabase Auth

In your Supabase dashboard → Authentication → URL Configuration:
- **Site URL**: `http://localhost:3000` (change for production)
- **Redirect URLs**: Add `http://localhost:3000/auth/callback`

### 5. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## ✦ Deploying to Vercel

### Option A: Vercel CLI

```bash
npm install -g vercel
vercel
```

### Option B: Vercel Dashboard

1. Push to GitHub
2. Import repo at [vercel.com/new](https://vercel.com/new)
3. Set environment variables in Vercel dashboard:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_APP_URL` → your Vercel domain, e.g. `https://moonlight.vercel.app`

4. After first deploy, update Supabase:
   - Site URL → your Vercel domain
   - Add your Vercel domain to Redirect URLs

---

## ✦ Application Flow

```
Landing Page (/)
  ↓
Register (/auth/register)  ←→  Login (/auth/login)
  ↓                                    ↓
         Dashboard (/dashboard)
                  ↓
         Create Wizard (/create)
           Step 1: Recipient name
           Step 2: Hero title + subtitle
           Step 3: Love letter (greeting, paragraphs, signature)
           Step 4: Reasons I love you (5 cards)
           Step 5: Gallery photos + optional music
           Step 6: Surprise cards (tap-to-reveal)
           Step 7: Ending poem
                  ↓ (auto slug generated, saved to Supabase)
         Share Screen (/share/[slug])
           • Unique shareable URL
           • Downloadable QR code (PNG with branding)
           • Copy link button
                  ↓ (recipient receives link)
         Romantic Page (/p/[slug])
           • Cinematic intro loading screen
           • Floating lavender petals
           • Twinkling particle stars
           • Custom lilac cursor
           • 7 scroll-reveal sections
           • Optional background music
           • Tap-to-reveal surprise cards
```

---

## ✦ Design System

All CSS variables defined in `globals.css`:

```css
--black:     #08060f   /* Deep space background */
--deep:      #0d0a18
--violet:    #3d2b6b   /* Deep purple accents */
--orchid:    #8b5cf6   /* Primary purple */
--lilac:     #c4b5fd   /* Lilac highlights */
--lavender:  #ddd6fe   /* Lavender text */
--mist:      #ede9fe   /* Misty white */
--moonwhite: #f4f2ff   /* Near-white headings */
```

Fonts:
- **Cormorant Garant** — Serif display, used for headings and poetry
- **Nunito** — Sans-serif body, used for UI and prose

---

## ✦ Extending the App

### Adding a new section
1. Add columns to `love_pages` in Supabase
2. Update `src/types/index.ts` with new fields
3. Add a new `StepXxx` component in `src/components/editor/Steps.tsx`
4. Add the step to `STEPS` array in `create/page.tsx`
5. Add the section render in `RomanticPage.tsx`
6. Update `pageToContent()` in `src/lib/pages.ts`

### Enabling photo uploads to Supabase Storage
In `StepGallery.tsx`, replace the URL input with a file dropzone:
```tsx
import { createClient } from '@/lib/supabase/client';

async function uploadPhoto(file: File, userId: string) {
  const supabase = createClient();
  const path = `${userId}/${Date.now()}-${file.name}`;
  const { data } = await supabase.storage
    .from('love-photos')
    .upload(path, file);
  const { data: { publicUrl } } = supabase.storage
    .from('love-photos')
    .getPublicUrl(path);
  return publicUrl;
}
```
