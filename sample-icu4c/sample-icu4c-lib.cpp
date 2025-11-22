#include "sample-icu4c-lib.h"

#include <unicode/unistr.h>

void string_eval_test(void)
{
   // a surrogate pair of the world emoji between `a` and `B`
   const std::u16string_view& u16str = u"a" u"\xD83C\xDF0E" u"B";

   icu::UnicodeString str = u16str;

   puts(std::format("string: {:s}", str.toUTF8String<std::u8string>()).c_str());

   puts(std::format("char count: {:d}", str.countChar32()).c_str());
   puts(std::format("byte count: {:d}", str.toUTF8String<std::u8string>().length()).c_str());

   puts(std::format("lower: {:s}", str.toLower().toUTF8String<std::u8string>()).c_str());
   puts(std::format("upper: {:s}", str.toUpper().toUTF8String<std::u8string>()).c_str());

   puts("");
}
