# Global Agent Notes

- Invariant: usage of Slack, Linear, and Notion (including their MCP tools) is strictly read-only. Agents may read, search, list, and fetch content, but must never create, update, delete, send, post, comment, react, or otherwise mutate any state in these services. Any write action requires explicit user approval in the current turn.
- Invariant: never open a PR (draft or otherwise) that the user did not explicitly ask for, and never open a PR that is not intended to be merged (probes, experiments, throwaway CI runs) unless the user explicitly asks for that specific PR. Find another way to gather evidence, or ask first.
