import type { Locale } from "./config";

export const messages: Record<Locale, Record<string, string>> = {
  en: {
    nav_home: "Home",
    nav_explore: "Explore",
    nav_reports: "Reports",
    nav_archive: "Archive",
    nav_about: "About",
    nav_sign_in: "Sign in",
    nav_admin: "Control room",
  },
  ru: {
    nav_home: "Главная",
    nav_explore: "Исследовать",
    nav_reports: "Отчёты",
    nav_archive: "Архив",
    nav_about: "О проекте",
    nav_sign_in: "Войти",
    nav_admin: "Панель управления",
  },
  az: {
    nav_home: "Ana səhifə",
    nav_explore: "Araşdır",
    nav_reports: "Hesabatlar",
    nav_archive: "Arxiv",
    nav_about: "Haqqında",
    nav_sign_in: "Daxil ol",
    nav_admin: "İdarəetmə",
  },
};
