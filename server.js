require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

const app = express();
app.use(cors());
app.use(express.json());

app.post('/ask-jiji', async (req, res) => {
  try {
    const { query } = req.body;
    if (!query || typeof query !== 'string' || query.length < 3) {
      return res.status(400).json({ error: 'Valid query (min 3 chars) required' });
    }

    const keywords = query.toLowerCase().split(' ').filter(w => w.length > 2);
    const { data: resources, error } = await supabase
      .from('resources')
      .select('id, title, type, storage_path, description')
      .ilike('description', `%rag%`);

    if (error) throw error;

    const answer = `Explanation of "${query}": Retrieval-Augmented Generation (RAG) combines large language models with external data sources to improve answer accuracy.`;

    await supabase.from('queries').insert({ query, user_id: null });

    const resourceLinks = resources?.map(r => ({
      title: r.title,
      url: `${supabaseUrl}/storage/v1/object/public/jiji/${r.storage_path}`
    })) || [];

    res.json({ answer, resources: resourceLinks });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal error' });
  }
});

app.listen(3000, () => console.log('Server running on http://localhost:3000'));