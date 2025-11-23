#ifndef SAMPLE_ICU4C_LIB_H
#define SAMPLE_ICU4C_LIB_H

#include <string>
#include <format>

template <>
struct std::formatter<std::u8string, char> : std::formatter<std::string_view, char> {
      template<class format_context_t>
      auto format(const std::u8string& u8str, format_context_t& fmtctx) const
      {
         return std::formatter<std::string_view, char>::format(std::string_view(reinterpret_cast<const char*>(u8str.data()), u8str.size()), fmtctx);
      }
};

void string_eval_test(void);

#endif
