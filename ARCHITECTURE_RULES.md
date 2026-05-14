# ALKAN SIGORTA MOBILE - ARCHITECTURE & DEVELOPMENT RULES

This project is a highly professional, enterprise-level Flutter application. You MUST strictly obey the following rules in every interaction, without exception.

1. **ZERO HARDCODE:** Never hardcode URLs, API keys, or timeout durations. Always use `flutter_dotenv` (.env file). UI texts, colors, and paddings must be centralized in `lib/core/constants/`. No "magic numbers" in the UI.
2. **FEATURE-FIRST CLEAN ARCHITECTURE:** The project is structured by features, not layers. Use the path: `lib/features/{feature_name}/(data, domain, presentation)`. Shared logic goes to `lib/core/`.
3. **RADICAL ERROR HANDLING (FAIL-FAST):** No silent catch blocks. Use custom `Failure` classes for exceptions (e.g., ServerFailure, NetworkFailure). The UI must explicitly show errors to the user.
4. **STRICT SOLID & DEPENDENCY INJECTION:** Strictly apply SOLID principles. Use `get_it` for dependency injection. The Presentation layer (UI) must NEVER instantiate services or API classes directly. Always use Repository Interfaces (Dependency Inversion).
5. **SEPARATION OF CONCERNS:** The Presentation layer must be completely unaware of HTTP requests, Dio, or JSON serialization. The Domain layer must be pure Dart (no Flutter imports). Data layer handles API and DTOs.
6. **CLEAN CODE & WIDGET MODULARITY:** Keep `build` methods small. If a widget exceeds 50-60 lines, extract it into a smaller, reusable custom widget. 
7. **DECLARATIVE ROUTING:** Do NOT use `Navigator.push`. All routing must be handled centrally via the `go_router` package in `lib/core/routes/`.
8. **RESPONSIVE UI & THEMING:** Ensure the UI does not break on different screen sizes using responsive techniques. Do not inject colors directly into widgets; always use `Theme.of(context)` for Dark/Light mode compatibility.
9. **NO PLACEHOLDERS (CRITICAL):** When generating or updating code, NEVER leave placeholders like `// ... rest of the code` or `// ... existing code`. You must output the COMPLETE and fully functional file content every single time to prevent data loss.