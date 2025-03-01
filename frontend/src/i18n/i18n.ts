import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

import enTranslation from './locales/en.json';
import koTranslation from './locales/ko.json';
import jaTranslation from './locales/ja.json';

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources: {
      en: {
        translation: enTranslation
      },
      ko: {
        translation: koTranslation
      },
      ja: {
        translation: jaTranslation
      }
    },
    fallbackLng: 'ko',
    debug: import.meta.env.DEV,
    interpolation: {
      escapeValue: false
    }
  });

export default i18n;
