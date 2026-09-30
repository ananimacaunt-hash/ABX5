import { defaultLocale, type Locale } from "./config";
import { messages } from "./messages";

export function t(key: string, locale: Locale = defaultLocale) {
  return messages[locale][key] ?? messages.en[key] ?? key;
}
