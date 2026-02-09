-- Create tables first
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS queries (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  query TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS resources (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  type TEXT CHECK (type IN ('ppt', 'video')),
  storage_path TEXT NOT NULL,
  description TEXT NOT NULL
);

-- Enable RLS security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE queries ENABLE ROW LEVEL SECURITY; 
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;

-- RLS Policies (security rules)
CREATE POLICY "Users view own profile" ON profiles 
FOR SELECT TO authenticated USING (auth.uid() = id);

CREATE POLICY "Any view public profiles" ON profiles 
FOR SELECT TO public USING (true);

CREATE POLICY "Users insert own profile" ON profiles 
FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

CREATE POLICY "Users update own profile" ON profiles 
FOR UPDATE TO authenticated USING (auth.uid() = id);

CREATE POLICY "Users view own queries" ON queries 
FOR SELECT TO authenticated USING (auth.uid() = user_id);

CREATE POLICY "Users insert own queries" ON queries 
FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Public read resources" ON resources 
FOR SELECT TO public USING (true);

-- Sample Jiji RAG data
INSERT INTO resources (title, type, storage_path, description) VALUES
('Explain RAG PPT', 'ppt', 'rag-presentation.ppt', 'Retrieval-Augmented Generation basics presentation'),
('RAG Video Tutorial', 'video', 'rag-video.mp4', 'Explain RAG video tutorial')
ON CONFLICT DO NOTHING;