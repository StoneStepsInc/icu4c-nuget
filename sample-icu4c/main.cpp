#include "lib/sample-icu4c-lib.h"

#include <unicode/uclean.h>
#include <unicode/udata.h>
#include <unicode/unistr.h>
#include <unicode/numfmt.h>
#include <unicode/datefmt.h>
#include <unicode/ustream.h>
#include <unicode/calendar.h>
#include <unicode/coll.h>

#include <cstdint>
#include <cinttypes>
#include <cstdlib>
#include <cstdio>
#include <memory>
#include <string_view>
#include <stdexcept>
#include <algorithm>
#include <format>

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

void locale_format_test(const icu::Locale& locale)
{
   UErrorCode status = U_ZERO_ERROR;

   icu::UnicodeString locale_name;
   locale.getDisplayName(locale_name);

   puts(std::format("locale: {:s}", locale_name.toUTF8String<std::u8string>()).c_str());

   double number = 12345.678;

   std::unique_ptr<icu::NumberFormat> numFmtUS(icu::NumberFormat::createInstance(locale, status));
   icu::UnicodeString num_locale;
   numFmtUS->format(number, num_locale);

   puts(std::format("number: {:s}", num_locale.toUTF8String<std::u8string>()).c_str());

   UDate date = icu::Calendar::getNow();

   std::unique_ptr<icu::DateFormat> dateFmtUS(icu::DateFormat::createDateTimeInstance(icu::DateFormat::kFull, icu::DateFormat::kFull, locale));
   icu::UnicodeString date_locale;
   dateFmtUS->format(date, date_locale);

   puts(std::format("date: {:s}", date_locale.toUTF8String<std::u8string>()).c_str());

   puts("");
}

struct coll_less_t {
   std::unique_ptr<icu::Collator> collator;
   
   coll_less_t(const icu::Locale& locale)
   {
      UErrorCode status = U_ZERO_ERROR;

      collator.reset(icu::Collator::createInstance(locale, status));

      // may return U_USING_FALLBACK_WARNING if the exact locale is not available
      if(status != U_ZERO_ERROR && !collator)
         throw std::runtime_error(std::format("Cannot create a collator ({:s})", u_errorName(status)));

      if(status == U_USING_FALLBACK_WARNING) {
         status = U_ZERO_ERROR;

         icu::Locale actual_locale = collator->getLocale(ULOC_ACTUAL_LOCALE, status);

         if(status != U_ZERO_ERROR)
            throw std::runtime_error(std::format("Cannot query the actual collator locale ({:s})", u_errorName(status)));

         puts(std::format("Using the fallback locale \"{:s}\" in the collator", actual_locale.getName()).c_str());
      }

      collator->setAttribute(UCOL_STRENGTH, UCOL_TERTIARY, status);

      if(status != U_ZERO_ERROR)
         throw std::runtime_error(std::format("Cannot set the collator strength ({:s})", u_errorName(status)));
   }

   bool operator () (const std::u8string& a, const std::u8string& b) const
   {
      UErrorCode status = U_ZERO_ERROR;

      // ICU must be compiled with C++20 for icu::StringPiece to accept `const char8_t*`
      UCollationResult result = collator->compareUTF8(
            icu::StringPiece(a.c_str(), static_cast<uint32_t>(a.length())),
            icu::StringPiece(b.c_str(), static_cast<uint32_t>(b.length())), status);

      if(status != U_ZERO_ERROR)
         throw std::runtime_error(std::format("Cannot collate strings \"{:s}\" and \"{:s}\" ({:s})",
                           reinterpret_cast<const char*>(a.c_str()),
                           reinterpret_cast<const char*>(b.c_str()), u_errorName(status)));

      return result == UCOL_LESS;
   }
};

void locale_sort_test()
{
   std::vector<std::u8string> strs = {u8"a", u8"ae", u8"ä", u8"b", u8"A", u8"B", u8"AE", u8"Ä"};

   icu::Locale locale("de_CH@collation=phonebook");

   icu::UnicodeString locale_name;
   locale.getDisplayName(locale_name);

   puts(std::format("locale: {:s}", locale_name.toUTF8String<std::u8string>()).c_str());

   std::sort(strs.begin(), strs.end(), coll_less_t(locale));

   fputs("collation sort: ", stdout);

   // should sort as `a A ae AE ä Ä b B`
   for(std::u8string str : strs)
      fputs(std::format("{:s} ", str).c_str(), stdout);

   puts("");

   std::sort(strs.begin(), strs.end());

   fputs("binary sort   : ", stdout);

   // should sort as `A AE B a ae b Ä ä`
   for(std::u8string str : strs)
      fputs(std::format("{:s} ", str).c_str(), stdout);

   puts("");
}

int main(void)
{
   try {
      // the default encoding is the current Windows code page, typically Win-1252
      SetConsoleOutputCP(CP_UTF8);

      UErrorCode status = U_ZERO_ERROR;

      // uncomment this line if icudt.lib is removed from the project
      //u_setDataDirectory("x64\\Debug");
      u_init(&status);

      if(status != U_ZERO_ERROR)
         throw std::runtime_error(std::format("Cannot initialize ICU4C ({:s})", u_errorName(status)));

      string_eval_test();

      locale_format_test(icu::Locale("en", "US"));
      locale_format_test(icu::Locale("de", "CH"));

      locale_sort_test();

      return EXIT_SUCCESS;
   }
   catch(const std::exception& error) {
      fputs(std::format("ERROR: {:s}\n", error.what()).c_str(), stderr);
   }
}
