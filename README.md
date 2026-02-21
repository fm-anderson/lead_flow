# Lead Flow 🚀

**Lead Flow** is a lean, pluggable lead-generation engine built in Ruby. It is designed to scan social platforms for high-intent leads using a **"Filter First, AI Second"** philosophy.

---

## 💡 The Philosophy

Most AI lead generation tools are over-engineered and expensive. They use LLMs to read every single post, leading to massive API bills and unnecessary complexity.

**Lead Flow** takes a different approach:

1.  **Regex-Based Filtering:** Use basic string/regex matching to discard 99% of the noise (posts without specific keywords) for free.
2.  **Local AI Verification:** Use your local `gemini-cli` only for the final 1%—to confirm if a post represents a real opportunity based on **your specific business context**.
3.  **Pluggable Connectors:** Decoupled architecture allows anyone to add new platforms (Reddit, LinkedIn, X) by mapping them to our standard schema.

---

## 🏗️ Architecture

The project is built as a series of decoupled Ruby modules:

- **Connectors:** Platform-specific adapters (`LeadFlow::Connectors`) that fetch and "normalize" data.
- **The Core:**
  - `Filter`: High-speed regex matching.
  - `Evaluator`: The "AI Brain" powered by `gemini-cli` (using `gemini-2.5-flash`).
  - `Deduplicator`: File-based persistence to ensure you never process the same lead twice.
- **Notifiers:** (Coming Soon) Dispatchers for Slack, Telegram, or Discord.

---

## 🚀 Getting Started

### 1. Prerequisites
- Ruby 3.x
- [Gemini CLI](https://github.com/google/gemini-cli) installed and configured on your machine.

### 2. Installation
```bash
git clone https://github.com/fm-anderson/lead_flow.git
cd lead_flow
bundle install
```

### 3. Configuration
Copy the example environment file:
```bash
cp .env.example .env
```
Edit `.env` and provide your business context:
```env
# What do you do?
BUSINESS_CONTEXT="I provide a simple, no-subscription invoicing tool for freelancers."

# What pain points do you solve?
BUSINESS_SOLUTIONS="Expensive subscriptions, complex billing, manual invoice creation."

# What subreddits and keywords should we watch?
REDDIT_SUBREDDITS=freelance,smallbusiness
MONITOR_KEYWORDS=invoice,billing,payments
```

### 4. Run the Engine
```bash
./bin/lead_flow
```
Confirmed leads will be logged to `db/confirmed_leads.log`.

---

## 📋 Standardized Lead Schema

Every connector transforms data into this uniform structure:

```json
{
  "source": "reddit",
  "external_id": "t3_1r5ziuc",
  "author": "user_name",
  "title": "Need help with billing",
  "content": "Does anyone know a good invoicing tool for freelancers?",
  "url": "https://reddit.com/r/...",
  "metadata": {},
  "captured_at": "2026-02-20T19:00:00Z"
}
```

---

## 🤝 Contributing

We love contributions!
1.  **Create a New Connector:** Add a class to `lib/lead_flow/connectors/` that inherits from `Base`.
2.  **Add a Notifier:** Help us build the Slack or Telegram dispatchers in `lib/lead_flow/notifiers/`.
3.  **Refine the Evaluator:** Improve the AI prompt in `lib/lead_flow/core/evaluator.rb`.

Please ensure you add RSpec tests for any new features in the `spec/` directory.
