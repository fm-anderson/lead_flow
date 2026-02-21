# Lead Flow

**Lead Flow** is a lean, pluggable lead-generation engine built in Ruby. It’s designed to scan social platforms for high-intent leads using a **"Filter First, AI Second"** philosophy.

---

## The Philosophy

Most AI-powered lead generation tools are over-engineered and expensive. They use LLMs to read every single post, leading to massive API bills and unnecessary complexity.

**Lead Flow** takes a different approach:

1.  **Regex-Based Filtering:** Use basic programming to discard 99% of the noise (posts without specific keywords) for free.
2.  **AI Context Verification:** Use an LLM only for the final 1%—to understand if a user is actually looking for a service.
3.  **Pluggable Connectors:** Decoupled architecture allows anyone to add new platforms (Reddit, LinkedIn, X) by simply mapping them to our standard JSON schema.

## Architecture

The project is built as a series of decoupled Ruby modules:

- **Connectors:** Platform-specific adapters that fetch and "normalize" data.
- **The Core:**
  - `Filter`: High-speed string matching to find potential leads.
  - `Evaluator`: The "AI Brain" that confirms intent.
  - `Deduplicator`: Ensures you never get notified for the same post twice.
- **Notifiers:** Dispatchers for Slack, Telegram, Discord or Email.

## 📋 Standardized Lead Schema

To keep the engine provider-agnostic, every connector transforms data into this uniform JSON structure:

```json
{
  "source": "reddit",
  "external_id": "123xyz",
  "author": "user_name",
  "title": "Need help with billing",
  "content": "Does anyone know a good invoicing tool for freelancers?",
  "url": "[https://reddit.com/r/](https://reddit.com/r/)...",
  "metadata": {},
  "captured_at": "2026-02-20T19:00:00Z"
}
```
