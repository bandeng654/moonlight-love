-- =====================================================
-- MOONLIGHT LOVE — Supabase Database Schema
-- Run this in your Supabase SQL editor
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────────────
-- PROFILES TABLE
-- Extends auth.users with display name
-- ─────────────────────────────────────────────────────
CREATE TABLE public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (new.id, new.raw_user_meta_data->>'display_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ─────────────────────────────────────────────────────
-- LOVE_PAGES TABLE
-- Stores all user-created romantic pages
-- ─────────────────────────────────────────────────────
CREATE TABLE public.love_pages (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  slug            TEXT UNIQUE NOT NULL,

  -- Recipient
  recipient_name  TEXT NOT NULL DEFAULT 'You',

  -- Section: Intro screen
  intro_title     TEXT NOT NULL DEFAULT 'For You',
  intro_subtitle  TEXT NOT NULL DEFAULT 'A message from the heart',

  -- Section: Hero
  hero_eyebrow    TEXT NOT NULL DEFAULT 'Written with all my love',
  hero_title_1    TEXT NOT NULL DEFAULT 'You are',
  hero_title_2    TEXT NOT NULL DEFAULT 'my everything',
  hero_subtitle   TEXT,

  -- Section: Opening
  opening_label   TEXT,
  opening_quote   TEXT,
  opening_body    TEXT,

  -- Section: Letter
  letter_label    TEXT,
  letter_greeting TEXT,
  letter_paragraphs JSONB DEFAULT '[]'::jsonb,
  letter_signature TEXT,

  -- Section: Reasons
  reasons_title   TEXT,
  reasons_items   JSONB DEFAULT '[]'::jsonb,

  -- Section: Gallery
  gallery_title   TEXT,
  gallery_subtitle TEXT,
  gallery_photos  JSONB DEFAULT '[]'::jsonb,
  -- Each item: { url?: string, caption: string, icon: string }

  -- Section: Surprises
  surprise_label  TEXT,
  surprise_title  TEXT,
  surprise_subtitle TEXT,
  surprise_cards  JSONB DEFAULT '[]'::jsonb,
  -- Each item: { icon, title, hint, reveal }

  -- Section: Ending
  ending_title_1  TEXT,
  ending_title_2  TEXT,
  ending_poem     TEXT,
  ending_cta_text TEXT,
  ending_footer   TEXT,

  -- Music
  music_url       TEXT,
  music_label     TEXT,

  -- Meta
  is_published    BOOLEAN DEFAULT TRUE,
  views           INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX love_pages_user_id_idx ON public.love_pages(user_id);
CREATE INDEX love_pages_slug_idx ON public.love_pages(slug);

-- RLS
ALTER TABLE public.love_pages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view published pages"
  ON public.love_pages FOR SELECT
  USING (is_published = TRUE);

CREATE POLICY "Users can view own pages"
  ON public.love_pages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own pages"
  ON public.love_pages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own pages"
  ON public.love_pages FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own pages"
  ON public.love_pages FOR DELETE
  USING (auth.uid() = user_id);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER love_pages_updated_at
  BEFORE UPDATE ON public.love_pages
  FOR EACH ROW EXECUTE PROCEDURE public.set_updated_at();

-- ─────────────────────────────────────────────────────
-- STORAGE BUCKET for photos
-- ─────────────────────────────────────────────────────
-- Run in Supabase Dashboard > Storage:
-- Create bucket "love-photos" with public access

INSERT INTO storage.buckets (id, name, public)
VALUES ('love-photos', 'love-photos', TRUE)
ON CONFLICT DO NOTHING;

CREATE POLICY "Authenticated users can upload photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'love-photos'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Anyone can view photos"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'love-photos');

CREATE POLICY "Users can delete own photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'love-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
