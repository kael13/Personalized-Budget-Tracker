import express from "express";
import path from "path";
import { createServer as createViteServer } from "vite";
import dotenv from "dotenv";

dotenv.config();

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(express.json());

  // Helper function to query OpenRouter
  async function callOpenRouter(apiKey: string, model: string, budgets: any): Promise<string> {
    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
        "HTTP-Referer": "http://localhost:3000",
        "X-Title": "BloomBudget Tracker"
      },
      body: JSON.stringify({
        model: model,
        messages: [
          {
            role: "user",
            content: `
              Analyze the following budget data and provide 3 short, helpful, and "girly pop" style recommendations for saving money. 
              The tone should be supportive, modern, and fun. 
              Data: ${JSON.stringify(budgets)}
              
              Format the response strictly as a JSON array of strings: ["rec1", "rec2", "rec3"]. 
              Return only the JSON array. Do not include markdown code block formatting or any extra conversational text.
            `
          }
        ]
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`OpenRouter API status ${response.status}: ${errorText}`);
    }

    const data: any = await response.json();
    
    // Check if the response payload has an error (OpenRouter returns 200 with error block for upstream rate-limiting)
    if (data.error) {
      const errMsg = data.error.message || JSON.stringify(data.error);
      const errCode = data.error.code;
      throw new Error(`OpenRouter payload error (code ${errCode}): ${errMsg}`);
    }

    const content = data.choices?.[0]?.message?.content;
    if (!content) {
      throw new Error("Empty response choices from OpenRouter");
    }

    return content;
  }

  // OpenRouter API Proxy with high-availability model fallback
  app.post("/api/analyze-spending", async (req, res) => {
    try {
      const { budgets } = req.body;
      const openRouterApiKey = process.env.OPENROUTER_API_KEY;

      if (!openRouterApiKey) {
        return res.status(500).json({ error: "OpenRouter API key not configured" });
      }

      let content = "";
      const primaryModel = "deepseek/deepseek-v4-flash:free";
      const fallbackModel = "openai/gpt-oss-120b:free";

      try {
        console.log(`[AI Proxy] Attempting primary model: ${primaryModel}...`);
        content = await callOpenRouter(openRouterApiKey, primaryModel, budgets);
      } catch (primaryError: any) {
        console.warn(`[AI Proxy] Primary model ${primaryModel} failed: ${primaryError.message}. Triggering fallback model: ${fallbackModel}...`);
        content = await callOpenRouter(openRouterApiKey, fallbackModel, budgets);
      }

      const recommendations = JSON.parse(content.replace(/```json|```/g, "").trim());
      res.json({ recommendations });
    } catch (error: any) {
      console.error("OpenRouter Analysis Error (Both primary and fallback models failed):", error);
      res.status(500).json({ error: "Failed to analyze spending via OpenRouter" });
    }
  });

  // Vite middleware for development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
}

startServer();
