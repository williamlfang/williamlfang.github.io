# C&#43;&#43;日志模块:loguru


loguru 是一款轻量级的　ｃ&#43;&#43; 日志模块，提供了多种格式的日志输出，并且可以使用 fmtlib 的格式化。
&lt;!--more--&gt;

总结：

- 如果使用 `fmtlib`，则需要在编译静态库的时候，设置 `include` 之前添加

  ```c&#43;&#43;
  #define LOGURU_USE_FMTLIB 1
  #include &#34;loguru.hpp&#34;
  ```

- 编译可执行的时候，需要确保先链接 `loguru`，然后在链接 `fmt`

  ```cmake
  target_link_libraries(ctpmd PRIVATE
      thostmduserapi_se
      # NanoLog
      # fmt
      loguru
      fmt  ## 确定 fmt 是在后面
      yaml-cpp
  )
  ```


![loguru](./loguru.png &#34;loguru&#34;)



# 安装

由于我们后面需要使用 `fmtlib` 模块用于更好的输出日志，所以需要先进行安装。

## 安装 `fmtlib`

```bash
cd ~/Downloads
git clone git@github.com:fmtlib/fmt.git

mkdir build
cd build
sudo cmake ..
sudo make
sudo install
```

## 安装 `loguru`

首先，我们把这个项目拷贝到本地，然后再通过修改相应的模块。

```bash
git clone git@github.com:emilk/loguru.git
```

# 定制 `loguru`

由于这个提供了源代码，我们可以根据公司的日志记录需要，进行定制化配置。

## 修改日志头文件

```c&#43;&#43;
// vim loguru.cpp
// 1. 修改日志表头的显示
// #define LOGURU_PREAMBLE_WIDTH (53 &#43; LOGURU_THREADNAME_WIDTH &#43; LOGURU_FILENAME_WIDTH)
#define LOGURU_PREAMBLE_WIDTH (57 &#43; LOGURU_THREADNAME_WIDTH &#43; LOGURU_FILENAME_WIDTH)
```

## 修改 micro 精确的时间戳

```c&#43;&#43;
// vim loguru.cpp
//## 2. 增加 micro 时间戳
void write_date_time(char* buff, size_t buff_size)
{
    auto now = system_clock::now();
    long long ms_since_epoch = duration_cast&lt;microseconds&gt;(now.time_since_epoch()).count();
    time_t sec_since_epoch = time_t(ms_since_epoch / 1000000);
    tm time_info;
    localtime_r(&amp;sec_since_epoch, &amp;time_info);
    snprintf(buff, buff_size, &#34;%04d%02d%02d_%02d%02d%02d.%06lld&#34;,
        1900 &#43; time_info.tm_year, 1 &#43; time_info.tm_mon, time_info.tm_mday,
        time_info.tm_hour, time_info.tm_min, time_info.tm_sec, ms_since_epoch % 1000000);
}
```

## 打印 micro 时间戳

```c&#43;&#43;
// vim loguru.cpp
// 打印 micro 时间戳
static void print_preamble(char* out_buff, size_t out_buff_size, Verbosity verbosity, const char* file, unsigned line)
{
    if (out_buff_size == 0) { return; }
    out_buff[0] = &#39;\0&#39;;
    if (!g_preamble) { return; }
    long long ms_since_epoch = duration_cast&lt;microseconds&gt;(system_clock::now().time_since_epoch()).count();
    time_t sec_since_epoch = time_t(ms_since_epoch / 1000000);
    tm time_info;
    localtime_r(&amp;sec_since_epoch, &amp;time_info);

    auto uptime_ms = duration_cast&lt;milliseconds&gt;(steady_clock::now() - s_start_time).count();
    auto uptime_sec = uptime_ms / 1000.0;

    char thread_name[LOGURU_THREADNAME_WIDTH &#43; 1] = {0};
    get_thread_name(thread_name, LOGURU_THREADNAME_WIDTH &#43; 1, true);

    if (s_strip_file_path) {
        file = filename(file);
    }

    char level_buff[6];
    const char* custom_level_name = get_verbosity_name(verbosity);
    if (custom_level_name) {
        snprintf(level_buff, sizeof(level_buff) - 1, &#34;%s&#34;, custom_level_name);
    } else {
        snprintf(level_buff, sizeof(level_buff) - 1, &#34;% 4d&#34;, verbosity);
    }

    long pos = 0;

    if (g_preamble_date &amp;&amp; pos &lt; out_buff_size) {
        pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%04d-%02d-%02d &#34;,
                         1900 &#43; time_info.tm_year, 1 &#43; time_info.tm_mon, time_info.tm_mday);
    }
    if (g_preamble_time &amp;&amp; pos &lt; out_buff_size) {
        pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%02d:%02d:%02d.%06lld &#34;,
                       time_info.tm_hour, time_info.tm_min, time_info.tm_sec, ms_since_epoch % 1000000);
    }
    if (g_preamble_uptime &amp;&amp; pos &lt; out_buff_size) {
        //pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;(%8.3fs) &#34;,
        //               uptime_sec);
        pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;(%9.3fs) &#34;,
                       uptime_sec);
    }
    if (g_preamble_thread &amp;&amp; pos &lt; out_buff_size) {
        pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;[%-*s]&#34;,
                       LOGURU_THREADNAME_WIDTH, thread_name);
    }
    if (g_preamble_file &amp;&amp; pos &lt; out_buff_size) {
        char shortened_filename[LOGURU_FILENAME_WIDTH &#43; 1];
        snprintf(shortened_filename, LOGURU_FILENAME_WIDTH &#43; 1, &#34;%s&#34;, file);
        pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%*s:%-5u &#34;,
                       LOGURU_FILENAME_WIDTH, shortened_filename, line);
    }
    if (g_preamble_verbose &amp;&amp; pos &lt; out_buff_size) {
        pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%4s&#34;,
                       level_buff);
    }
    if (g_preamble_pipe &amp;&amp; pos &lt; out_buff_size) {
        pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;| &#34;);
    }
}
```

## 修改函数运行时间计数器

```c&#43;&#43;
// vim loguru.cpp
// 3.修改函数运行时间
#if LOGURU_VERBOSE_SCOPE_ENDINGS
            auto duration_sec = (now_ns() - _start_time_ns) / 1e9;
#if LOGURU_USE_FMTLIB
            //auto buff = textprintf(&#34;{:.{}f} s: {:s}&#34;, duration_sec, LOGURU_SCOPE_TIME_PRECISION, _name);
            auto buff = textprintf(&#34;[{:.{}f} s]: {:s}&#34;, duration_sec, LOGURU_SCOPE_TIME_PRECISION, _name);
#else
            //auto buff = textprintf(&#34;%.*f s: %s&#34;, LOGURU_SCOPE_TIME_PRECISION, duration_sec, _name);
            auto buff = textprintf(&#34;[%.*f s: %s]&#34;, LOGURU_SCOPE_TIME_PRECISION, duration_sec, _name);
#endif


```

## 增加 fmtlib 支持

```hpp
// vim loguru.hpp
// 增加 fmt 支持

#define LOGURU_USE_FMTLIB 1
#include &#34;loguru.hpp&#34;

#ifndef LOGURU_SCOPE_TIME_PRECISION
	// Resolution of scope timers. 3=ms, 6=us, 9=ns
	// #define LOGURU_SCOPE_TIME_PRECISION 3
	#define LOGURU_SCOPE_TIME_PRECISION 6
#endif

#ifndef LOGURU_FILENAME_WIDTH
	// Width of the column containing the file name
	// #define LOGURU_FILENAME_WIDTH 23
    #define LOGURU_FILENAME_WIDTH 18
#endif

#ifndef LOGURU_THREADNAME_WIDTH
	// Width of the column containing the thread name
	// #define LOGURU_THREADNAME_WIDTH 16
    #define LOGURU_THREADNAME_WIDTH 12
#endif
```

# 编译静态库

```cmake
## CMakeLists.txt
project(loguru)
cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_FLAGS &#34;${CMAKE_CXX_FLAGS} -o3&#34;)

set(LIBRARY_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/)
add_library(loguru STATIC loguru.cpp)
target_link_libraries(loguru fmt)
```

# 我的配置方案

## `loguru.hpp`

```c&#43;&#43;
/*
Loguru logging library for C&#43;&#43;, by Emil Ernerfeldt.
www.github.com/emilk/loguru
If you find Loguru useful, please let me know on twitter or in a mail!
Twitter: @ernerfeldt
Mail:    emil.ernerfeldt@gmail.com
Website: www.ilikebigbits.com

# License
	This software is in the public domain. Where that dedication is not
	recognized, you are granted a perpetual, irrevocable license to
	copy, modify and distribute it as you see fit.

# Inspiration
	Much of Loguru was inspired by GLOG, https://code.google.com/p/google-glog/.
	The choice of public domain is fully due Sean T. Barrett
	and his wonderful stb libraries at https://github.com/nothings/stb.

# Version history
	* Version 0.1.0 - 2015-03-22 - Works great on Mac.
	* Version 0.2.0 - 2015-09-17 - Removed the only dependency.
	* Version 0.3.0 - 2015-10-02 - Drop-in replacement for most of GLOG
	* Version 0.4.0 - 2015-10-07 - Single-file!
	* Version 0.5.0 - 2015-10-17 - Improved file logging
	* Version 0.6.0 - 2015-10-24 - Add stack traces
	* Version 0.7.0 - 2015-10-27 - Signals
	* Version 0.8.0 - 2015-10-30 - Color logging.
	* Version 0.9.0 - 2015-11-26 - ABORT_S and proper handling of FATAL
	* Version 1.0.0 - 2016-02-14 - ERROR_CONTEXT
	* Version 1.1.0 - 2016-02-19 - -v OFF, -v INFO etc
	* Version 1.1.1 - 2016-02-20 - textprintf vs strprintf
	* Version 1.1.2 - 2016-02-22 - Remove g_alsologtostderr
	* Version 1.1.3 - 2016-02-29 - ERROR_CONTEXT as linked list
	* Version 1.2.0 - 2016-03-19 - Add get_thread_name()
	* Version 1.2.1 - 2016-03-20 - Minor fixes
	* Version 1.2.2 - 2016-03-29 - Fix issues with set_fatal_handler throwing an exception
	* Version 1.2.3 - 2016-05-16 - Log current working directory in loguru::init().
	* Version 1.2.4 - 2016-05-18 - Custom replacement for -v in loguru::init() by bjoernpollex
	* Version 1.2.5 - 2016-05-18 - Add ability to print ERROR_CONTEXT of parent thread.
	* Version 1.2.6 - 2016-05-19 - Bug fix regarding VLOG verbosity argument lacking ().
	* Version 1.2.7 - 2016-05-23 - Fix PATH_MAX problem.
	* Version 1.2.8 - 2016-05-26 - Add shutdown() and remove_all_callbacks()
	* Version 1.2.9 - 2016-06-09 - Use a monotonic clock for uptime.
	* Version 1.3.0 - 2016-07-20 - Fix issues with callback flush/close not being called.
	* Version 1.3.1 - 2016-07-20 - Add LOGURU_UNSAFE_SIGNAL_HANDLER to toggle stacktrace on signals.
	* Version 1.3.2 - 2016-07-20 - Add loguru::arguments()
	* Version 1.4.0 - 2016-09-15 - Semantic versioning &#43; add loguru::create_directories
	* Version 1.4.1 - 2016-09-29 - Customize formating with LOGURU_FILENAME_WIDTH
	* Version 1.5.0 - 2016-12-22 - LOGURU_USE_FMTLIB by kolis and LOGURU_WITH_FILEABS by scinart
	* Version 1.5.1 - 2017-08-08 - Terminal colors on Windows 10 thanks to looki
	* Version 1.6.0 - 2018-01-03 - Add LOGURU_RTTI and LOGURU_STACKTRACES settings
	* Version 1.7.0 - 2018-01-03 - Add ability to turn off the preamble with loguru::g_preamble
	* Version 1.7.1 - 2018-04-05 - Add function get_fatal_handler
	* Version 1.7.2 - 2018-04-22 - Fix a bug where large file names could cause stack corruption (thanks @ccamporesi)
	* Version 1.8.0 - 2018-04-23 - Shorten long file names to keep preamble fixed width
	* Version 1.9.0 - 2018-09-22 - Adjust terminal colors, add LOGURU_VERBOSE_SCOPE_ENDINGS, add LOGURU_SCOPE_TIME_PRECISION, add named log levels
	* Version 2.0.0 - 2018-09-22 - Split loguru.hpp into loguru.hpp and loguru.cpp
	* Version 2.1.0 - 2019-09-23 - Update fmtlib &#43; add option to loguru::init to NOT set main thread name.

# Compiling
	Just include &lt;loguru.hpp&gt; where you want to use Loguru.
	Then, in one .cpp file #include &lt;loguru.cpp&gt;
	Make sure you compile with -std=c&#43;&#43;11 -lstdc&#43;&#43; -lpthread -ldl

# Usage
	For details, please see the official documentation at emilk.github.io/loguru

	#include &lt;loguru.hpp&gt;

	int main(int argc, char* argv[]) {
		loguru::init(argc, argv);

		// Put every log message in &#34;everything.log&#34;:
		loguru::add_file(&#34;everything.log&#34;, loguru::Append, loguru::Verbosity_MAX);

		LOG_F(INFO, &#34;The magic number is %d&#34;, 42);
	}

*/

#if defined(LOGURU_IMPLEMENTATION)
	#error &#34;You are defining LOGURU_IMPLEMENTATION. This is for older versions of Loguru. You should now instead include loguru.cpp (or build it and link with it)&#34;
#endif

// Disable all warnings from gcc/clang:
#if defined(__clang__)
	#pragma clang system_header
#elif defined(__GNUC__)
	#pragma GCC system_header
#endif

#ifndef LOGURU_HAS_DECLARED_FORMAT_HEADER
#define LOGURU_HAS_DECLARED_FORMAT_HEADER

// Semantic versioning. Loguru version can be printed with printf(&#34;%d.%d.%d&#34;, LOGURU_VERSION_MAJOR, LOGURU_VERSION_MINOR, LOGURU_VERSION_PATCH);
#define LOGURU_VERSION_MAJOR 2
#define LOGURU_VERSION_MINOR 1
#define LOGURU_VERSION_PATCH 0

#if defined(_MSC_VER)
#include &lt;sal.h&gt;	// Needed for _In_z_ etc annotations
#endif

// ----------------------------------------------------------------------------

#ifndef LOGURU_EXPORT
	// Define to your project&#39;s export declaration if needed for use in a shared library.
	#define LOGURU_EXPORT
#endif

#ifndef LOGURU_SCOPE_TEXT_SIZE
	// Maximum length of text that can be printed by a LOG_SCOPE.
	// This should be long enough to get most things, but short enough not to clutter the stack.
	#define LOGURU_SCOPE_TEXT_SIZE 196
#endif

#ifndef LOGURU_FILENAME_WIDTH
	// Width of the column containing the file name
	// #define LOGURU_FILENAME_WIDTH 23
    #define LOGURU_FILENAME_WIDTH 15
#endif

#ifndef LOGURU_THREADNAME_WIDTH
	// Width of the column containing the thread name
	// #define LOGURU_THREADNAME_WIDTH 16
    #define LOGURU_THREADNAME_WIDTH 15
#endif

#ifndef LOGURU_SCOPE_TIME_PRECISION
	// Resolution of scope timers. 3=ms, 6=us, 9=ns
	//#define LOGURU_SCOPE_TIME_PRECISION 3
	#define LOGURU_SCOPE_TIME_PRECISION 6
#endif

#ifndef LOGURU_CATCH_SIGABRT
	// Should Loguru catch SIGABRT to print stack trace etc?
	#define LOGURU_CATCH_SIGABRT 1
#endif

#ifndef LOGURU_VERBOSE_SCOPE_ENDINGS
	// Show milliseconds and scope name at end of scope.
	#define LOGURU_VERBOSE_SCOPE_ENDINGS 1
#endif

#ifndef LOGURU_REDEFINE_ASSERT
	#define LOGURU_REDEFINE_ASSERT 0
#endif

#ifndef LOGURU_WITH_STREAMS
	#define LOGURU_WITH_STREAMS 0
#endif

#ifndef LOGURU_REPLACE_GLOG
	#define LOGURU_REPLACE_GLOG 0
#endif

#if LOGURU_REPLACE_GLOG
	#undef LOGURU_WITH_STREAMS
	#define LOGURU_WITH_STREAMS 1
#endif

#if defined(LOGURU_UNSAFE_SIGNAL_HANDLER)
	#error &#34;You are defining LOGURU_UNSAFE_SIGNAL_HANDLER. This is for older versions of Loguru. You should now instead set the unsafe_signal_handler option when you call loguru::init.&#34;
#endif

#if LOGURU_IMPLEMENTATION
	#undef LOGURU_WITH_STREAMS
	#define LOGURU_WITH_STREAMS 1
#endif

#ifndef LOGURU_USE_FMTLIB
	#define LOGURU_USE_FMTLIB 0
#endif

#ifndef LOGURU_WITH_FILEABS
	#define LOGURU_WITH_FILEABS 0
#endif

#ifndef LOGURU_RTTI
#if defined(__clang__)
	#if __has_feature(cxx_rtti)
		#define LOGURU_RTTI 1
	#endif
#elif defined(__GNUG__)
	#if defined(__GXX_RTTI)
		#define LOGURU_RTTI 1
	#endif
#elif defined(_MSC_VER)
	#if defined(_CPPRTTI)
		#define LOGURU_RTTI 1
	#endif
#endif
#endif

// --------------------------------------------------------------------
// Utility macros

#define LOGURU_CONCATENATE_IMPL(s1, s2) s1 ## s2
#define LOGURU_CONCATENATE(s1, s2) LOGURU_CONCATENATE_IMPL(s1, s2)

#ifdef __COUNTER__
#   define LOGURU_ANONYMOUS_VARIABLE(str) LOGURU_CONCATENATE(str, __COUNTER__)
#else
#   define LOGURU_ANONYMOUS_VARIABLE(str) LOGURU_CONCATENATE(str, __LINE__)
#endif

#if defined(__clang__) || defined(__GNUC__)
	// Helper macro for declaring functions as having similar signature to printf.
	// This allows the compiler to catch format errors at compile-time.
	#define LOGURU_PRINTF_LIKE(fmtarg, firstvararg) __attribute__((__format__ (__printf__, fmtarg, firstvararg)))
	#define LOGURU_FORMAT_STRING_TYPE const char*
#elif defined(_MSC_VER)
	#define LOGURU_PRINTF_LIKE(fmtarg, firstvararg)
	#define LOGURU_FORMAT_STRING_TYPE _In_z_ _Printf_format_string_ const char*
#else
	#define LOGURU_PRINTF_LIKE(fmtarg, firstvararg)
	#define LOGURU_FORMAT_STRING_TYPE const char*
#endif

// Used to mark log_and_abort for the benefit of the static analyzer and optimizer.
#if defined(_MSC_VER)
#define LOGURU_NORETURN __declspec(noreturn)
#else
#define LOGURU_NORETURN __attribute__((noreturn))
#endif

#if defined(_MSC_VER)
#define LOGURU_PREDICT_FALSE(x) (x)
#define LOGURU_PREDICT_TRUE(x)  (x)
#else
#define LOGURU_PREDICT_FALSE(x) (__builtin_expect(x,     0))
#define LOGURU_PREDICT_TRUE(x)  (__builtin_expect(!!(x), 1))
#endif

#if LOGURU_USE_FMTLIB
	#include &lt;fmt/format.h&gt;
	#define LOGURU_FMT(x) &#34;{:&#34; #x &#34;}&#34;
#else
	#define LOGURU_FMT(x) &#34;%&#34; #x
#endif

#ifdef _WIN32
	#define STRDUP(str) _strdup(str)
#else
	#define STRDUP(str) strdup(str)
#endif

// --------------------------------------------------------------------

namespace loguru
{
	// Simple RAII ownership of a char*.
	class LOGURU_EXPORT Text
	{
	public:
		explicit Text(char* owned_str) : _str(owned_str) {}
		~Text();
		Text(Text&amp;&amp; t)
		{
			_str = t._str;
			t._str = nullptr;
		}
		Text(Text&amp; t) = delete;
		Text&amp; operator=(Text&amp; t) = delete;
		void operator=(Text&amp;&amp; t) = delete;

		const char* c_str() const { return _str; }
		bool empty() const { return _str == nullptr || *_str == &#39;\0&#39;; }

		char* release()
		{
			auto result = _str;
			_str = nullptr;
			return result;
		}

	private:
		char* _str;
	};

	// Like printf, but returns the formated text.
#if LOGURU_USE_FMTLIB
	LOGURU_EXPORT
	Text vtextprintf(const char* format, fmt::format_args args);

	template&lt;typename... Args&gt;
	LOGURU_EXPORT
	Text textprintf(LOGURU_FORMAT_STRING_TYPE format, const Args&amp;... args) {
		return vtextprintf(format, fmt::make_format_args(args...));
	}
#else
	LOGURU_EXPORT
	Text textprintf(LOGURU_FORMAT_STRING_TYPE format, ...) LOGURU_PRINTF_LIKE(1, 2);
#endif

	// Overloaded for variadic template matching.
	LOGURU_EXPORT
	Text textprintf();

	using Verbosity = int;

#undef FATAL
#undef ERROR
#undef WARNING
#undef INFO
#undef MAX

	enum NamedVerbosity : Verbosity
	{
		// Used to mark an invalid verbosity. Do not log to this level.
		Verbosity_INVALID = -10, // Never do LOG_F(INVALID)

		// You may use Verbosity_OFF on g_stderr_verbosity, but for nothing else!
		Verbosity_OFF     = -9, // Never do LOG_F(OFF)

		// Prefer to use ABORT_F or ABORT_S over LOG_F(FATAL) or LOG_S(FATAL).
		Verbosity_FATAL   = -3,
		Verbosity_ERROR   = -2,
		Verbosity_WARNING = -1,

		// Normal messages. By default written to stderr.
		Verbosity_INFO    =  0,

		// Same as Verbosity_INFO in every way.
		Verbosity_0       =  0,

		// Verbosity levels 1-9 are generally not written to stderr, but are written to file.
		Verbosity_1       = &#43;1,
		Verbosity_2       = &#43;2,
		Verbosity_3       = &#43;3,
		Verbosity_4       = &#43;4,
		Verbosity_5       = &#43;5,
		Verbosity_6       = &#43;6,
		Verbosity_7       = &#43;7,
		Verbosity_8       = &#43;8,
		Verbosity_9       = &#43;9,

		// Don not use higher verbosity levels, as that will make grepping log files harder.
		Verbosity_MAX     = &#43;9,
	};

	struct Message
	{
		// You would generally print a Message by just concating the buffers without spacing.
		// Optionally, ignore preamble and indentation.
		Verbosity   verbosity;   // Already part of preamble
		const char* filename;    // Already part of preamble
		unsigned    line;        // Already part of preamble
		const char* preamble;    // Date, time, uptime, thread, file:line, verbosity.
		const char* indentation; // Just a bunch of spacing.
		const char* prefix;      // Assertion failure info goes here (or &#34;&#34;).
		const char* message;     // User message goes here.
	};

	/* Everything with a verbosity equal or greater than g_stderr_verbosity will be
	written to stderr. You can set this in code or via the -v argument.
	Set to loguru::Verbosity_OFF to write nothing to stderr.
	Default is 0, i.e. only log ERROR, WARNING and INFO are written to stderr.
	*/
	LOGURU_EXPORT extern Verbosity g_stderr_verbosity;
	LOGURU_EXPORT extern bool      g_colorlogtostderr; // True by default.
	LOGURU_EXPORT extern unsigned  g_flush_interval_ms; // 0 (unbuffered) by default.
	LOGURU_EXPORT extern bool      g_preamble_header; // Prepend each log start by a descriptions line with all columns name? True by default.
	LOGURU_EXPORT extern bool      g_preamble; // Prefix each log line with date, time etc? True by default.

	/* Specify the verbosity used by loguru to log its info messages including the header
	logged when logged::init() is called or on exit. Default is 0 (INFO).
	*/
	LOGURU_EXPORT extern Verbosity g_internal_verbosity;

	// Turn off individual parts of the preamble
	LOGURU_EXPORT extern bool      g_preamble_date; // The date field
	LOGURU_EXPORT extern bool      g_preamble_time; // The time of the current day
	LOGURU_EXPORT extern bool      g_preamble_uptime; // The time since init call
	LOGURU_EXPORT extern bool      g_preamble_thread; // The logging thread
	LOGURU_EXPORT extern bool      g_preamble_file; // The file from which the log originates from
	LOGURU_EXPORT extern bool      g_preamble_verbose; // The verbosity field
	LOGURU_EXPORT extern bool      g_preamble_pipe; // The pipe symbol right before the message

	// May not throw!
	typedef void (*log_handler_t)(void* user_data, const Message&amp; message);
	typedef void (*close_handler_t)(void* user_data);
	typedef void (*flush_handler_t)(void* user_data);

	// May throw if that&#39;s how you&#39;d like to handle your errors.
	typedef void (*fatal_handler_t)(const Message&amp; message);

	// Given a verbosity level, return the level&#39;s name or nullptr.
	typedef const char* (*verbosity_to_name_t)(Verbosity verbosity);

	// Given a verbosity level name, return the verbosity level or
	// Verbosity_INVALID if name is not recognized.
	typedef Verbosity (*name_to_verbosity_t)(const char* name);

	// Runtime options passed to loguru::init
	struct Options
	{
		// This allows you to use something else instead of &#34;-v&#34; via verbosity_flag.
		// Set to nullptr to if you don&#39;t want Loguru to parse verbosity from the args.&#39;
		const char* verbosity_flag = &#34;-v&#34;;

		// loguru::init will set the name of the calling thread to this.
		// If you don&#39;t want Loguru to set the name of the main thread,
		// set this to nullptr.
		// NOTE: on SOME platforms loguru::init will only overwrite the thread name
		// if a thread name has not already been set.
		// To always set a thread name, use loguru::set_thread_name instead.
		const char* main_thread_name = &#34;main thread&#34;;

		// Make Loguru try to do unsafe but useful things,
		// like printing a stack trace, when catching signals.
		// This may lead to bad things like deadlocks in certain situations.
		bool unsafe_signal_handler = true;
	};

	/*  Should be called from the main thread.
		You don&#39;t *need* to call this, but if you do you get:
			* Signal handlers installed
			* Program arguments logged
			* Working dir logged
			* Optional -v verbosity flag parsed
			* Main thread name set to &#34;main thread&#34;
			* Explanation of the preamble (date, threanmae etc) logged

		loguru::init() will look for arguments meant for loguru and remove them.
		Arguments meant for loguru are:
			-v n   Set loguru::g_stderr_verbosity level. Examples:
				-v 3        Show verbosity level 3 and lower.
				-v 0        Only show INFO, WARNING, ERROR, FATAL (default).
				-v INFO     Only show INFO, WARNING, ERROR, FATAL (default).
				-v WARNING  Only show WARNING, ERROR, FATAL.
				-v ERROR    Only show ERROR, FATAL.
				-v FATAL    Only show FATAL.
				-v OFF      Turn off logging to stderr.

		Tip: You can set g_stderr_verbosity before calling loguru::init.
		That way you can set the default but have the user override it with the -v flag.
		Note that -v does not affect file logging (see loguru::add_file).

		You can you something other than the -v flag by setting the verbosity_flag option.
	*/
	LOGURU_EXPORT
	void init(int&amp; argc, char* argv[], const Options&amp; options = {});

	// Will call remove_all_callbacks(). After calling this, logging will still go to stderr.
	// You generally don&#39;t need to call this.
	LOGURU_EXPORT
	void shutdown();

	// What ~ will be replaced with, e.g. &#34;/home/your_user_name/&#34;
	LOGURU_EXPORT
	const char* home_dir();

	/* Returns the name of the app as given in argv[0] but without leading path.
	   That is, if argv[0] is &#34;../foo/app&#34; this will return &#34;app&#34;.
	*/
	LOGURU_EXPORT
	const char* argv0_filename();

	// Returns all arguments given to loguru::init(), but escaped with a single space as separator.
	LOGURU_EXPORT
	const char* arguments();

	// Returns the path to the current working dir when loguru::init() was called.
	LOGURU_EXPORT
	const char* current_dir();

	// Returns the part of the path after the last / or \ (if any).
	LOGURU_EXPORT
	const char* filename(const char* path);

	// e.g. &#34;foo/bar/baz.ext&#34; will create the directories &#34;foo/&#34; and &#34;foo/bar/&#34;
	LOGURU_EXPORT
	bool create_directories(const char* file_path_const);

	// Writes date and time with millisecond precision, e.g. &#34;20151017_161503.123&#34;
	LOGURU_EXPORT
	void write_date_time(char* buff, unsigned buff_size);

	// Helper: thread-safe version strerror
	LOGURU_EXPORT
	Text errno_as_text();

	/* Given a prefix of e.g. &#34;~/loguru/&#34; this might return
	   &#34;/home/your_username/loguru/app_name/20151017_161503.123.log&#34;

	   where &#34;app_name&#34; is a sanitized version of argv[0].
	*/
	LOGURU_EXPORT
	void suggest_log_path(const char* prefix, char* buff, unsigned buff_size);

	enum FileMode { Truncate, Append };

	/*  Will log to a file at the given path.
		Any logging message with a verbosity lower or equal to
		the given verbosity will be included.
		The function will create all directories in &#39;path&#39; if needed.
		If path starts with a ~, it will be replaced with loguru::home_dir()
		To stop the file logging, just call loguru::remove_callback(path) with the same path.
	*/
	LOGURU_EXPORT
	bool add_file(const char* path, FileMode mode, Verbosity verbosity);

	/*  Will be called right before abort().
		You can for instance use this to print custom error messages, or throw an exception.
		Feel free to call LOG:ing function from this, but not FATAL ones! */
	LOGURU_EXPORT
	void set_fatal_handler(fatal_handler_t handler);

	// Get the current fatal handler, if any. Default value is nullptr.
	LOGURU_EXPORT
	fatal_handler_t get_fatal_handler();

	/*  Will be called on each log messages with a verbosity less or equal to the given one.
		Useful for displaying messages on-screen in a game, for example.
		The given on_close is also expected to flush (if desired).
	*/
	LOGURU_EXPORT
	void add_callback(
		const char*     id,
		log_handler_t   callback,
		void*           user_data,
		Verbosity       verbosity,
		close_handler_t on_close = nullptr,
		flush_handler_t on_flush = nullptr);

	/*  Set a callback that returns custom verbosity level names. If callback
		is nullptr or returns nullptr, default log names will be used.
	*/
	LOGURU_EXPORT
	void set_verbosity_to_name_callback(verbosity_to_name_t callback);

	/*  Set a callback that returns the verbosity level matching a name. The
		callback should return Verbosity_INVALID if the name is not
		recognized.
	*/
	LOGURU_EXPORT
	void set_name_to_verbosity_callback(name_to_verbosity_t callback);

	/*  Get a custom name for a specific verbosity, if one exists, or nullptr. */
	LOGURU_EXPORT
	const char* get_verbosity_name(Verbosity verbosity);

	/*  Get the verbosity enum value from a custom 4-character level name, if one exists.
		If the name does not match a custom level name, Verbosity_INVALID is returned.
	*/
	LOGURU_EXPORT
	Verbosity get_verbosity_from_name(const char* name);

	// Returns true iff the callback was found (and removed).
	LOGURU_EXPORT
	bool remove_callback(const char* id);

	// Shut down all file logging and any other callback hooks installed.
	LOGURU_EXPORT
	void remove_all_callbacks();

	// Returns the maximum of g_stderr_verbosity and all file/custom outputs.
	LOGURU_EXPORT
	Verbosity current_verbosity_cutoff();

#if LOGURU_USE_FMTLIB
	// Internal functions
	void vlog(Verbosity verbosity, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, fmt::format_args args);
	void raw_vlog(Verbosity verbosity, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, fmt::format_args args);

	// Actual logging function. Use the LOG macro instead of calling this directly.
	template &lt;typename... Args&gt;
	LOGURU_EXPORT
	void log(Verbosity verbosity, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, const Args &amp;... args) {
	    vlog(verbosity, file, line, format, fmt::make_format_args(args...));
	}

	// Log without any preamble or indentation.
	template &lt;typename... Args&gt;
	LOGURU_EXPORT
	void raw_log(Verbosity verbosity, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, const Args &amp;... args) {
	    raw_vlog(verbosity, file, line, format, fmt::make_format_args(args...));
	}
#else // LOGURU_USE_FMTLIB?
	// Actual logging function. Use the LOG macro instead of calling this directly.
	LOGURU_EXPORT
	void log(Verbosity verbosity, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, ...) LOGURU_PRINTF_LIKE(4, 5);

	// Log without any preamble or indentation.
	LOGURU_EXPORT
	void raw_log(Verbosity verbosity, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, ...) LOGURU_PRINTF_LIKE(4, 5);
#endif // !LOGURU_USE_FMTLIB

	// Helper class for LOG_SCOPE_F
	class LOGURU_EXPORT LogScopeRAII
	{
	public:
		LogScopeRAII() : _file(nullptr) {} // No logging
		LogScopeRAII(Verbosity verbosity, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, ...) LOGURU_PRINTF_LIKE(5, 6);
		~LogScopeRAII();

#if defined(_MSC_VER) &amp;&amp; _MSC_VER &gt; 1800
		// older MSVC default move ctors close the scope on move. See
		// issue #43
		LogScopeRAII(LogScopeRAII&amp;&amp; other)
			: _verbosity(other._verbosity)
			, _file(other._file)
			, _line(other._line)
			, _indent_stderr(other._indent_stderr)
			, _start_time_ns(other._start_time_ns)
		{
			// Make sure the tmp object&#39;s destruction doesn&#39;t close the scope:
			other._file = nullptr;

			for (unsigned int i = 0; i &lt; LOGURU_SCOPE_TEXT_SIZE; &#43;&#43;i) {
				_name[i] = other._name[i];
			}
		}
#else
		LogScopeRAII(LogScopeRAII&amp;&amp;) = default;
#endif

	private:
		LogScopeRAII(const LogScopeRAII&amp;) = delete;
		LogScopeRAII&amp; operator=(const LogScopeRAII&amp;) = delete;
		void operator=(LogScopeRAII&amp;&amp;) = delete;

		Verbosity   _verbosity;
		const char* _file; // Set to null if we are disabled due to verbosity
		unsigned    _line;
		bool        _indent_stderr; // Did we?
		long long   _start_time_ns;
		char        _name[LOGURU_SCOPE_TEXT_SIZE];
	};

	// Marked as &#39;noreturn&#39; for the benefit of the static analyzer and optimizer.
	// stack_trace_skip is the number of extrace stack frames to skip above log_and_abort.
#if LOGURU_USE_FMTLIB
	LOGURU_EXPORT
	LOGURU_NORETURN void vlog_and_abort(int stack_trace_skip, const char* expr, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, fmt::format_args);
	template &lt;typename... Args&gt;
	LOGURU_EXPORT
	LOGURU_NORETURN void log_and_abort(int stack_trace_skip, const char* expr, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, const Args&amp;... args) {
	    vlog_and_abort(stack_trace_skip, expr, file, line, format, fmt::make_format_args(args...));
	}
#else
	LOGURU_EXPORT
	LOGURU_NORETURN void log_and_abort(int stack_trace_skip, const char* expr, const char* file, unsigned line, LOGURU_FORMAT_STRING_TYPE format, ...) LOGURU_PRINTF_LIKE(5, 6);
#endif
	LOGURU_EXPORT
	LOGURU_NORETURN void log_and_abort(int stack_trace_skip, const char* expr, const char* file, unsigned line);

	// Flush output to stderr and files.
	// If g_flush_interval_ms is set to non-zero, this will be called automatically this often.
	// If not set, you do not need to call this at all.
	LOGURU_EXPORT
	void flush();

	template&lt;class T&gt; inline Text format_value(const T&amp;)                    { return textprintf(&#34;N/A&#34;);     }
	template&lt;&gt;        inline Text format_value(const char&amp; v)               { return textprintf(LOGURU_FMT(c),   v); }
	template&lt;&gt;        inline Text format_value(const int&amp; v)                { return textprintf(LOGURU_FMT(d),   v); }
	template&lt;&gt;        inline Text format_value(const unsigned int&amp; v)       { return textprintf(LOGURU_FMT(u),   v); }
	template&lt;&gt;        inline Text format_value(const long&amp; v)               { return textprintf(LOGURU_FMT(lu),  v); }
	template&lt;&gt;        inline Text format_value(const unsigned long&amp; v)      { return textprintf(LOGURU_FMT(ld),  v); }
	template&lt;&gt;        inline Text format_value(const long long&amp; v)          { return textprintf(LOGURU_FMT(llu), v); }
	template&lt;&gt;        inline Text format_value(const unsigned long long&amp; v) { return textprintf(LOGURU_FMT(lld), v); }
	template&lt;&gt;        inline Text format_value(const float&amp; v)              { return textprintf(LOGURU_FMT(f),   v); }
	template&lt;&gt;        inline Text format_value(const double&amp; v)             { return textprintf(LOGURU_FMT(f),   v); }

	/* Thread names can be set for the benefit of readable logs.
	   If you do not set the thread name, a hex id will be shown instead.
	   These thread names may or may not be the same as the system thread names,
	   depending on the system.
	   Try to limit the thread name to 15 characters or less. */
	LOGURU_EXPORT
	void set_thread_name(const char* name);

	/* Returns the thread name for this thread.
	   On OSX this will return the system thread name (settable from both within and without Loguru).
	   On other systems it will return whatever you set in set_thread_name();
	   If no thread name is set, this will return a hexadecimal thread id.
	   length should be the number of bytes available in the buffer.
	   17 is a good number for length.
	   right_align_hext_id means any hexadecimal thread id will be written to the end of buffer.
	*/
	LOGURU_EXPORT
	void get_thread_name(char* buffer, unsigned long long length, bool right_align_hext_id);

	/* Generates a readable stacktrace as a string.
	   &#39;skip&#39; specifies how many stack frames to skip.
	   For instance, the default skip (1) means:
	   don&#39;t include the call to loguru::stacktrace in the stack trace. */
	LOGURU_EXPORT
	Text stacktrace(int skip = 1);

	/*  Add a string to be replaced with something else in the stack output.

		For instance, instead of having a stack trace look like this:
			0x41f541 some_function(std::basic_ofstream&lt;char, std::char_traits&lt;char&gt; &gt;&amp;)
		You can clean it up with:
			auto verbose_type_name = loguru::demangle(typeid(std::ofstream).name());
			loguru::add_stack_cleanup(verbose_type_name.c_str(); &#34;std::ofstream&#34;);
		So the next time you will instead see:
			0x41f541 some_function(std::ofstream&amp;)

		`replace_with_this` must be shorter than `find_this`.
	*/
	LOGURU_EXPORT
	void add_stack_cleanup(const char* find_this, const char* replace_with_this);

	// Example: demangle(typeid(std::ofstream).name()) -&gt; &#34;std::basic_ofstream&lt;char, std::char_traits&lt;char&gt; &gt;&#34;
	LOGURU_EXPORT
	Text demangle(const char* name);

	// ------------------------------------------------------------------------
	/*
	Not all terminals support colors, but if they do, and g_colorlogtostderr
	is set, Loguru will write them to stderr to make errors in red, etc.

	You also have the option to manually use them, via the function below.

	Note, however, that if you do, the color codes could end up in your logfile!

	This means if you intend to use them functions you should either:
		* Use them on the stderr/stdout directly (bypass Loguru).
		* Don&#39;t add file outputs to Loguru.
		* Expect some \e[1m things in your logfile.

	Usage:
		printf(&#34;%sRed%sGreen%sBold green%sClear again\n&#34;,
			   loguru::terminal_red(), loguru::terminal_green(),
			   loguru::terminal_bold(), loguru::terminal_reset());

	If the terminal at hand does not support colors the above output
	will just not have funky \e[1m things showing.
	*/

	// Do the output terminal support colors?
	LOGURU_EXPORT
	bool terminal_has_color();

	// Colors
	LOGURU_EXPORT const char* terminal_black();
	LOGURU_EXPORT const char* terminal_red();
	LOGURU_EXPORT const char* terminal_green();
	LOGURU_EXPORT const char* terminal_yellow();
	LOGURU_EXPORT const char* terminal_blue();
	LOGURU_EXPORT const char* terminal_purple();
	LOGURU_EXPORT const char* terminal_cyan();
	LOGURU_EXPORT const char* terminal_light_gray();
	LOGURU_EXPORT const char* terminal_light_red();
	LOGURU_EXPORT const char* terminal_white();

	// Formating
	LOGURU_EXPORT const char* terminal_bold();
	LOGURU_EXPORT const char* terminal_underline();

	// You should end each line with this!
	LOGURU_EXPORT const char* terminal_reset();

	// --------------------------------------------------------------------
	// Error context related:

	struct StringStream;

	// Use this in your EcEntryBase::print_value overload.
	LOGURU_EXPORT
	void stream_print(StringStream&amp; out_string_stream, const char* text);

	class LOGURU_EXPORT EcEntryBase
	{
	public:
		EcEntryBase(const char* file, unsigned line, const char* descr);
		~EcEntryBase();
		EcEntryBase(const EcEntryBase&amp;) = delete;
		EcEntryBase(EcEntryBase&amp;&amp;) = delete;
		EcEntryBase&amp; operator=(const EcEntryBase&amp;) = delete;
		EcEntryBase&amp; operator=(EcEntryBase&amp;&amp;) = delete;

		virtual void print_value(StringStream&amp; out_string_stream) const = 0;

		EcEntryBase* previous() const { return _previous; }

	// private:
		const char*  _file;
		unsigned     _line;
		const char*  _descr;
		EcEntryBase* _previous;
	};

	template&lt;typename T&gt;
	class EcEntryData : public EcEntryBase
	{
	public:
		using Printer = Text(*)(T data);

		EcEntryData(const char* file, unsigned line, const char* descr, T data, Printer&amp;&amp; printer)
			: EcEntryBase(file, line, descr), _data(data), _printer(printer) {}

		virtual void print_value(StringStream&amp; out_string_stream) const override
		{
			const auto str = _printer(_data);
			stream_print(out_string_stream, str.c_str());
		}

	private:
		T       _data;
		Printer _printer;
	};

	// template&lt;typename Printer&gt;
	// class EcEntryLambda : public EcEntryBase
	// {
	// public:
	// 	EcEntryLambda(const char* file, unsigned line, const char* descr, Printer&amp;&amp; printer)
	// 		: EcEntryBase(file, line, descr), _printer(std::move(printer)) {}

	// 	virtual void print_value(StringStream&amp; out_string_stream) const override
	// 	{
	// 		const auto str = _printer();
	// 		stream_print(out_string_stream, str.c_str());
	// 	}

	// private:
	// 	Printer _printer;
	// };

	// template&lt;typename Printer&gt;
	// EcEntryLambda&lt;Printer&gt; make_ec_entry_lambda(const char* file, unsigned line, const char* descr, Printer&amp;&amp; printer)
	// {
	// 	return {file, line, descr, std::move(printer)};
	// }

	template &lt;class T&gt;
	struct decay_char_array { using type = T; };

	template &lt;unsigned long long  N&gt;
	struct decay_char_array&lt;const char(&amp;)[N]&gt; { using type = const char*; };

	template &lt;class T&gt;
	struct make_const_ptr { using type = T; };

	template &lt;class T&gt;
	struct make_const_ptr&lt;T*&gt; { using type = const T*; };

	template &lt;class T&gt;
	struct make_ec_type { using type = typename make_const_ptr&lt;typename decay_char_array&lt;T&gt;::type&gt;::type; };

	/* 	A stack trace gives you the names of the function at the point of a crash.
		With ERROR_CONTEXT, you can also get the values of select local variables.
		Usage:

		void process_customers(const std::string&amp; filename)
		{
			ERROR_CONTEXT(&#34;Processing file&#34;, filename.c_str());
			for (int customer_index : ...)
			{
				ERROR_CONTEXT(&#34;Customer index&#34;, customer_index);
				...
			}
		}

		The context is in effect during the scope of the ERROR_CONTEXT.
		Use loguru::get_error_context() to get the contents of the active error contexts.

		Example result:

		------------------------------------------------
		[ErrorContext]                main.cpp:416   Processing file:    &#34;customers.json&#34;
		[ErrorContext]                main.cpp:417   Customer index:     42
		------------------------------------------------

		Error contexts are printed automatically on crashes, and only on crashes.
		This makes them much faster than logging the value of a variable.
	*/
	#define ERROR_CONTEXT(descr, data)                                             \
		const loguru::EcEntryData&lt;loguru::make_ec_type&lt;decltype(data)&gt;::type&gt;      \
			LOGURU_ANONYMOUS_VARIABLE(error_context_scope_)(                       \
				__FILE__, __LINE__, descr, data,                                   \
				static_cast&lt;loguru::EcEntryData&lt;loguru::make_ec_type&lt;decltype(data)&gt;::type&gt;::Printer&gt;(loguru::ec_to_text) ) // For better error messages

/*
	#define ERROR_CONTEXT(descr, data)                                 \
		const auto LOGURU_ANONYMOUS_VARIABLE(error_context_scope_)(    \
			loguru::make_ec_entry_lambda(__FILE__, __LINE__, descr,    \
				[=](){ return loguru::ec_to_text(data); }))
*/

	using EcHandle = const EcEntryBase*;

	/*
		Get a light-weight handle to the error context stack on this thread.
		The handle is valid as long as the current thread has no changes to its error context stack.
		You can pass the handle to loguru::get_error_context on another thread.
		This can be very useful for when you have a parent thread spawning several working threads,
		and you want the error context of the parent thread to get printed (too) when there is an
		error on the child thread. You can accomplish this thusly:

		void foo(const char* parameter)
		{
			ERROR_CONTEXT(&#34;parameter&#34;, parameter)
			const auto parent_ec_handle = loguru::get_thread_ec_handle();

			std::thread([=]{
				loguru::set_thread_name(&#34;child thread&#34;);
				ERROR_CONTEXT(&#34;parent context&#34;, parent_ec_handle);
				dangerous_code();
			}.join();
		}

	*/
	LOGURU_EXPORT
	EcHandle get_thread_ec_handle();

	// Get a string describing the current stack of error context. Empty string if there is none.
	LOGURU_EXPORT
	Text get_error_context();

	// Get a string describing the error context of the given thread handle.
	LOGURU_EXPORT
	Text get_error_context_for(EcHandle ec_handle);

	// ------------------------------------------------------------------------

	LOGURU_EXPORT Text ec_to_text(const char* data);
	LOGURU_EXPORT Text ec_to_text(char data);
	LOGURU_EXPORT Text ec_to_text(int data);
	LOGURU_EXPORT Text ec_to_text(unsigned int data);
	LOGURU_EXPORT Text ec_to_text(long data);
	LOGURU_EXPORT Text ec_to_text(unsigned long data);
	LOGURU_EXPORT Text ec_to_text(long long data);
	LOGURU_EXPORT Text ec_to_text(unsigned long long data);
	LOGURU_EXPORT Text ec_to_text(float data);
	LOGURU_EXPORT Text ec_to_text(double data);
	LOGURU_EXPORT Text ec_to_text(long double data);
	LOGURU_EXPORT Text ec_to_text(EcHandle);

	/*
	You can add ERROR_CONTEXT support for your own types by overloading ec_to_text. Here&#39;s how:

	some.hpp:
		namespace loguru {
			Text ec_to_text(MySmallType data)
			Text ec_to_text(const MyBigType* data)
		} // namespace loguru

	some.cpp:
		namespace loguru {
			Text ec_to_text(MySmallType small_value)
			{
				// Called only when needed, i.e. on a crash.
				std::string str = small_value.as_string(); // Format &#39;small_value&#39; here somehow.
				return Text{STRDUP(str.c_str())};
			}

			Text ec_to_text(const MyBigType* big_value)
			{
				// Called only when needed, i.e. on a crash.
				std::string str = big_value-&gt;as_string(); // Format &#39;big_value&#39; here somehow.
				return Text{STRDUP(str.c_str())};
			}
		} // namespace loguru

	Any file that include some.hpp:
		void foo(MySmallType small, const MyBigType&amp; big)
		{
			ERROR_CONTEXT(&#34;Small&#34;, small); // Copy ´small` by value.
			ERROR_CONTEXT(&#34;Big&#34;,   &amp;big);  // `big` should not change during this scope!
			....
		}
	*/
} // namespace loguru

// --------------------------------------------------------------------
// Logging macros

// LOG_F(2, &#34;Only logged if verbosity is 2 or higher: %d&#34;, some_number);
#define VLOG_F(verbosity, ...)                                                                     \
	((verbosity) &gt; loguru::current_verbosity_cutoff()) ? (void)0                                   \
									  : loguru::log(verbosity, __FILE__, __LINE__, __VA_ARGS__)

// LOG_F(INFO, &#34;Foo: %d&#34;, some_number);
#define LOG_F(verbosity_name, ...) VLOG_F(loguru::Verbosity_ ## verbosity_name, __VA_ARGS__)

#define VLOG_IF_F(verbosity, cond, ...)                                                            \
	((verbosity) &gt; loguru::current_verbosity_cutoff() || (cond) == false)                          \
		? (void)0                                                                                  \
		: loguru::log(verbosity, __FILE__, __LINE__, __VA_ARGS__)

#define LOG_IF_F(verbosity_name, cond, ...)                                                        \
	VLOG_IF_F(loguru::Verbosity_ ## verbosity_name, cond, __VA_ARGS__)

#define VLOG_SCOPE_F(verbosity, ...)                                                               \
	loguru::LogScopeRAII LOGURU_ANONYMOUS_VARIABLE(error_context_RAII_) =                          \
	((verbosity) &gt; loguru::current_verbosity_cutoff()) ? loguru::LogScopeRAII() :                  \
	loguru::LogScopeRAII(verbosity, __FILE__, __LINE__, __VA_ARGS__)

// Raw logging - no preamble, no indentation. Slightly faster than full logging.
#define RAW_VLOG_F(verbosity, ...)                                                                 \
	((verbosity) &gt; loguru::current_verbosity_cutoff()) ? (void)0                                   \
									  : loguru::raw_log(verbosity, __FILE__, __LINE__, __VA_ARGS__)

#define RAW_LOG_F(verbosity_name, ...) RAW_VLOG_F(loguru::Verbosity_ ## verbosity_name, __VA_ARGS__)

// Use to book-end a scope. Affects logging on all threads.
#define LOG_SCOPE_F(verbosity_name, ...)                                                           \
	VLOG_SCOPE_F(loguru::Verbosity_ ## verbosity_name, __VA_ARGS__)

#define LOG_SCOPE_FUNCTION(verbosity_name) LOG_SCOPE_F(verbosity_name, __func__)

// -----------------------------------------------
// ABORT_F macro. Usage:  ABORT_F(&#34;Cause of error: %s&#34;, error_str);

// Message is optional
#define ABORT_F(...) loguru::log_and_abort(0, &#34;ABORT: &#34;, __FILE__, __LINE__, __VA_ARGS__)

// --------------------------------------------------------------------
// CHECK_F macros:

#define CHECK_WITH_INFO_F(test, info, ...)                                                         \
	LOGURU_PREDICT_TRUE((test) == true) ? (void)0 : loguru::log_and_abort(0, &#34;CHECK FAILED:  &#34; info &#34;  &#34;, __FILE__,      \
													   __LINE__, ##__VA_ARGS__)

/* Checked at runtime too. Will print error, then call fatal_handler (if any), then &#39;abort&#39;.
   Note that the test must be boolean.
   CHECK_F(ptr); will not compile, but CHECK_F(ptr != nullptr); will. */
#define CHECK_F(test, ...) CHECK_WITH_INFO_F(test, #test, ##__VA_ARGS__)

#define CHECK_NOTNULL_F(x, ...) CHECK_WITH_INFO_F((x) != nullptr, #x &#34; != nullptr&#34;, ##__VA_ARGS__)

#define CHECK_OP_F(expr_left, expr_right, op, ...)                                                 \
	do                                                                                             \
	{                                                                                              \
		auto val_left = expr_left;                                                                 \
		auto val_right = expr_right;                                                               \
		if (! LOGURU_PREDICT_TRUE(val_left op val_right))                                          \
		{                                                                                          \
			auto str_left = loguru::format_value(val_left);                                        \
			auto str_right = loguru::format_value(val_right);                                      \
			auto fail_info = loguru::textprintf(&#34;CHECK FAILED:  &#34; LOGURU_FMT(s) &#34; &#34; LOGURU_FMT(s) &#34; &#34; LOGURU_FMT(s) &#34;  (&#34; LOGURU_FMT(s) &#34; &#34; LOGURU_FMT(s) &#34; &#34; LOGURU_FMT(s) &#34;)  &#34;,           \
				#expr_left, #op, #expr_right, str_left.c_str(), #op, str_right.c_str());           \
			auto user_msg = loguru::textprintf(__VA_ARGS__);                                       \
			loguru::log_and_abort(0, fail_info.c_str(), __FILE__, __LINE__,                        \
			                      LOGURU_FMT(s), user_msg.c_str());                                         \
		}                                                                                          \
	} while (false)

#ifndef LOGURU_DEBUG_LOGGING
	#ifndef NDEBUG
		#define LOGURU_DEBUG_LOGGING 1
	#else
		#define LOGURU_DEBUG_LOGGING 0
	#endif
#endif

#if LOGURU_DEBUG_LOGGING
	// Debug logging enabled:
	#define DLOG_F(verbosity_name, ...)     LOG_F(verbosity_name, __VA_ARGS__)
	#define DVLOG_F(verbosity, ...)         VLOG_F(verbosity, __VA_ARGS__)
	#define DLOG_IF_F(verbosity_name, ...)  LOG_IF_F(verbosity_name, __VA_ARGS__)
	#define DVLOG_IF_F(verbosity, ...)      VLOG_IF_F(verbosity, __VA_ARGS__)
	#define DRAW_LOG_F(verbosity_name, ...) RAW_LOG_F(verbosity_name, __VA_ARGS__)
	#define DRAW_VLOG_F(verbosity, ...)     RAW_VLOG_F(verbosity, __VA_ARGS__)
#else
	// Debug logging disabled:
	#define DLOG_F(verbosity_name, ...)
	#define DVLOG_F(verbosity, ...)
	#define DLOG_IF_F(verbosity_name, ...)
	#define DVLOG_IF_F(verbosity, ...)
	#define DRAW_LOG_F(verbosity_name, ...)
	#define DRAW_VLOG_F(verbosity, ...)
#endif

#define CHECK_EQ_F(a, b, ...) CHECK_OP_F(a, b, ==, ##__VA_ARGS__)
#define CHECK_NE_F(a, b, ...) CHECK_OP_F(a, b, !=, ##__VA_ARGS__)
#define CHECK_LT_F(a, b, ...) CHECK_OP_F(a, b, &lt; , ##__VA_ARGS__)
#define CHECK_GT_F(a, b, ...) CHECK_OP_F(a, b, &gt; , ##__VA_ARGS__)
#define CHECK_LE_F(a, b, ...) CHECK_OP_F(a, b, &lt;=, ##__VA_ARGS__)
#define CHECK_GE_F(a, b, ...) CHECK_OP_F(a, b, &gt;=, ##__VA_ARGS__)

#ifndef LOGURU_DEBUG_CHECKS
	#ifndef NDEBUG
		#define LOGURU_DEBUG_CHECKS 1
	#else
		#define LOGURU_DEBUG_CHECKS 0
	#endif
#endif

#if LOGURU_DEBUG_CHECKS
	// Debug checks enabled:
	#define DCHECK_F(test, ...)             CHECK_F(test, ##__VA_ARGS__)
	#define DCHECK_NOTNULL_F(x, ...)        CHECK_NOTNULL_F(x, ##__VA_ARGS__)
	#define DCHECK_EQ_F(a, b, ...)          CHECK_EQ_F(a, b, ##__VA_ARGS__)
	#define DCHECK_NE_F(a, b, ...)          CHECK_NE_F(a, b, ##__VA_ARGS__)
	#define DCHECK_LT_F(a, b, ...)          CHECK_LT_F(a, b, ##__VA_ARGS__)
	#define DCHECK_LE_F(a, b, ...)          CHECK_LE_F(a, b, ##__VA_ARGS__)
	#define DCHECK_GT_F(a, b, ...)          CHECK_GT_F(a, b, ##__VA_ARGS__)
	#define DCHECK_GE_F(a, b, ...)          CHECK_GE_F(a, b, ##__VA_ARGS__)
#else
	// Debug checks disabled:
	#define DCHECK_F(test, ...)
	#define DCHECK_NOTNULL_F(x, ...)
	#define DCHECK_EQ_F(a, b, ...)
	#define DCHECK_NE_F(a, b, ...)
	#define DCHECK_LT_F(a, b, ...)
	#define DCHECK_LE_F(a, b, ...)
	#define DCHECK_GT_F(a, b, ...)
	#define DCHECK_GE_F(a, b, ...)
#endif // NDEBUG


#if LOGURU_REDEFINE_ASSERT
	#undef assert
	#ifndef NDEBUG
		// Debug:
		#define assert(test) CHECK_WITH_INFO_F(!!(test), #test) // HACK
	#else
		#define assert(test)
	#endif
#endif // LOGURU_REDEFINE_ASSERT

#endif // LOGURU_HAS_DECLARED_FORMAT_HEADER

// ----------------------------------------------------------------------------
// .dP&#34;Y8 888888 88&#34;&#34;Yb 888888    db    8b    d8 .dP&#34;Y8
// `Ybo.&#34;   88   88__dP 88__     dPYb   88b  d88 `Ybo.&#34;
// o.`Y8b   88   88&#34;Yb  88&#34;&#34;    dP__Yb  88YbdP88 o.`Y8b
// 8bodP&#39;   88   88  Yb 888888 dP&#34;&#34;&#34;&#34;Yb 88 YY 88 8bodP&#39;

#if LOGURU_WITH_STREAMS
#ifndef LOGURU_HAS_DECLARED_STREAMS_HEADER
#define LOGURU_HAS_DECLARED_STREAMS_HEADER

/* This file extends loguru to enable std::stream-style logging, a la Glog.
   It&#39;s an optional feature behind the LOGURU_WITH_STREAMS settings
   because including it everywhere will slow down compilation times.
*/

#include &lt;cstdarg&gt;
#include &lt;sstream&gt; // Adds about 38 kLoC on clang.
#include &lt;string&gt;

namespace loguru
{
	// Like sprintf, but returns the formated text.
	LOGURU_EXPORT
	std::string strprintf(LOGURU_FORMAT_STRING_TYPE format, ...) LOGURU_PRINTF_LIKE(1, 2);

	// Like vsprintf, but returns the formated text.
	LOGURU_EXPORT
	std::string vstrprintf(LOGURU_FORMAT_STRING_TYPE format, va_list) LOGURU_PRINTF_LIKE(1, 0);

	class LOGURU_EXPORT StreamLogger
	{
	public:
		StreamLogger(Verbosity verbosity, const char* file, unsigned line) : _verbosity(verbosity), _file(file), _line(line) {}
		~StreamLogger() noexcept(false);

		template&lt;typename T&gt;
		StreamLogger&amp; operator&lt;&lt;(const T&amp; t)
		{
			_ss &lt;&lt; t;
			return *this;
		}

		// std::endl and other iomanip:s.
		StreamLogger&amp; operator&lt;&lt;(std::ostream&amp;(*f)(std::ostream&amp;))
		{
			f(_ss);
			return *this;
		}

	private:
		Verbosity   _verbosity;
		const char* _file;
		unsigned    _line;
		std::ostringstream _ss;
	};

	class LOGURU_EXPORT AbortLogger
	{
	public:
		AbortLogger(const char* expr, const char* file, unsigned line) : _expr(expr), _file(file), _line(line) { }
		LOGURU_NORETURN ~AbortLogger() noexcept(false);

		template&lt;typename T&gt;
		AbortLogger&amp; operator&lt;&lt;(const T&amp; t)
		{
			_ss &lt;&lt; t;
			return *this;
		}

		// std::endl and other iomanip:s.
		AbortLogger&amp; operator&lt;&lt;(std::ostream&amp;(*f)(std::ostream&amp;))
		{
			f(_ss);
			return *this;
		}

	private:
		const char*        _expr;
		const char*        _file;
		unsigned           _line;
		std::ostringstream _ss;
	};

	class LOGURU_EXPORT Voidify
	{
	public:
		Voidify() {}
		// This has to be an operator with a precedence lower than &lt;&lt; but higher than ?:
		void operator&amp;(const StreamLogger&amp;) { }
		void operator&amp;(const AbortLogger&amp;)  { }
	};

	/*  Helper functions for CHECK_OP_S macro.
		GLOG trick: The (int, int) specialization works around the issue that the compiler
		will not instantiate the template version of the function on values of unnamed enum type. */
	#define DEFINE_CHECK_OP_IMPL(name, op)                                                             \
		template &lt;typename T1, typename T2&gt;                                                            \
		inline std::string* name(const char* expr, const T1&amp; v1, const char* op_str, const T2&amp; v2)     \
		{                                                                                              \
			if (LOGURU_PREDICT_TRUE(v1 op v2)) { return NULL; }                                        \
			std::ostringstream ss;                                                                     \
			ss &lt;&lt; &#34;CHECK FAILED:  &#34; &lt;&lt; expr &lt;&lt; &#34;  (&#34; &lt;&lt; v1 &lt;&lt; &#34; &#34; &lt;&lt; op_str &lt;&lt; &#34; &#34; &lt;&lt; v2 &lt;&lt; &#34;)  &#34;;     \
			return new std::string(ss.str());                                                          \
		}                                                                                              \
		inline std::string* name(const char* expr, int v1, const char* op_str, int v2)                 \
		{                                                                                              \
			return name&lt;int, int&gt;(expr, v1, op_str, v2);                                               \
		}

	DEFINE_CHECK_OP_IMPL(check_EQ_impl, ==)
	DEFINE_CHECK_OP_IMPL(check_NE_impl, !=)
	DEFINE_CHECK_OP_IMPL(check_LE_impl, &lt;=)
	DEFINE_CHECK_OP_IMPL(check_LT_impl, &lt; )
	DEFINE_CHECK_OP_IMPL(check_GE_impl, &gt;=)
	DEFINE_CHECK_OP_IMPL(check_GT_impl, &gt; )
	#undef DEFINE_CHECK_OP_IMPL

	/*  GLOG trick: Function is overloaded for integral types to allow static const integrals
		declared in classes and not defined to be used as arguments to CHECK* macros. */
	template &lt;class T&gt;
	inline const T&amp;           referenceable_value(const T&amp;           t) { return t; }
	inline char               referenceable_value(char               t) { return t; }
	inline unsigned char      referenceable_value(unsigned char      t) { return t; }
	inline signed char        referenceable_value(signed char        t) { return t; }
	inline short              referenceable_value(short              t) { return t; }
	inline unsigned short     referenceable_value(unsigned short     t) { return t; }
	inline int                referenceable_value(int                t) { return t; }
	inline unsigned int       referenceable_value(unsigned int       t) { return t; }
	inline long               referenceable_value(long               t) { return t; }
	inline unsigned long      referenceable_value(unsigned long      t) { return t; }
	inline long long          referenceable_value(long long          t) { return t; }
	inline unsigned long long referenceable_value(unsigned long long t) { return t; }
} // namespace loguru

// -----------------------------------------------
// Logging macros:

// usage:  LOG_STREAM(INFO) &lt;&lt; &#34;Foo &#34; &lt;&lt; std::setprecision(10) &lt;&lt; some_value;
#define VLOG_IF_S(verbosity, cond)                                                                 \
	((verbosity) &gt; loguru::current_verbosity_cutoff() || (cond) == false)                          \
		? (void)0                                                                                  \
		: loguru::Voidify() &amp; loguru::StreamLogger(verbosity, __FILE__, __LINE__)
#define LOG_IF_S(verbosity_name, cond) VLOG_IF_S(loguru::Verbosity_ ## verbosity_name, cond)
#define VLOG_S(verbosity)              VLOG_IF_S(verbosity, true)
#define LOG_S(verbosity_name)          VLOG_S(loguru::Verbosity_ ## verbosity_name)

// -----------------------------------------------
// ABORT_S macro. Usage:  ABORT_S() &lt;&lt; &#34;Causo of error: &#34; &lt;&lt; details;

#define ABORT_S() loguru::Voidify() &amp; loguru::AbortLogger(&#34;ABORT: &#34;, __FILE__, __LINE__)

// -----------------------------------------------
// CHECK_S macros:

#define CHECK_WITH_INFO_S(cond, info)                                                              \
	LOGURU_PREDICT_TRUE((cond) == true)                                                            \
		? (void)0                                                                                  \
		: loguru::Voidify() &amp; loguru::AbortLogger(&#34;CHECK FAILED:  &#34; info &#34;  &#34;, __FILE__, __LINE__)

#define CHECK_S(cond) CHECK_WITH_INFO_S(cond, #cond)
#define CHECK_NOTNULL_S(x) CHECK_WITH_INFO_S((x) != nullptr, #x &#34; != nullptr&#34;)

#define CHECK_OP_S(function_name, expr1, op, expr2)                                                \
	while (auto error_string = loguru::function_name(#expr1 &#34; &#34; #op &#34; &#34; #expr2,                    \
													 loguru::referenceable_value(expr1), #op,      \
													 loguru::referenceable_value(expr2)))          \
		loguru::AbortLogger(error_string-&gt;c_str(), __FILE__, __LINE__)

#define CHECK_EQ_S(expr1, expr2) CHECK_OP_S(check_EQ_impl, expr1, ==, expr2)
#define CHECK_NE_S(expr1, expr2) CHECK_OP_S(check_NE_impl, expr1, !=, expr2)
#define CHECK_LE_S(expr1, expr2) CHECK_OP_S(check_LE_impl, expr1, &lt;=, expr2)
#define CHECK_LT_S(expr1, expr2) CHECK_OP_S(check_LT_impl, expr1, &lt; , expr2)
#define CHECK_GE_S(expr1, expr2) CHECK_OP_S(check_GE_impl, expr1, &gt;=, expr2)
#define CHECK_GT_S(expr1, expr2) CHECK_OP_S(check_GT_impl, expr1, &gt; , expr2)

#if LOGURU_DEBUG_LOGGING
	// Debug logging enabled:
	#define DVLOG_IF_S(verbosity, cond)     VLOG_IF_S(verbosity, cond)
	#define DLOG_IF_S(verbosity_name, cond) LOG_IF_S(verbosity_name, cond)
	#define DVLOG_S(verbosity)              VLOG_S(verbosity)
	#define DLOG_S(verbosity_name)          LOG_S(verbosity_name)
#else
	// Debug logging disabled:
	#define DVLOG_IF_S(verbosity, cond)                                                     \
		(true || (verbosity) &gt; loguru::current_verbosity_cutoff() || (cond) == false)       \
			? (void)0                                                                       \
			: loguru::Voidify() &amp; loguru::StreamLogger(verbosity, __FILE__, __LINE__)

	#define DLOG_IF_S(verbosity_name, cond) DVLOG_IF_S(loguru::Verbosity_ ## verbosity_name, cond)
	#define DVLOG_S(verbosity)              DVLOG_IF_S(verbosity, true)
	#define DLOG_S(verbosity_name)          DVLOG_S(loguru::Verbosity_ ## verbosity_name)
#endif

#if LOGURU_DEBUG_CHECKS
	// Debug checks enabled:
	#define DCHECK_S(cond)                  CHECK_S(cond)
	#define DCHECK_NOTNULL_S(x)             CHECK_NOTNULL_S(x)
	#define DCHECK_EQ_S(a, b)               CHECK_EQ_S(a, b)
	#define DCHECK_NE_S(a, b)               CHECK_NE_S(a, b)
	#define DCHECK_LT_S(a, b)               CHECK_LT_S(a, b)
	#define DCHECK_LE_S(a, b)               CHECK_LE_S(a, b)
	#define DCHECK_GT_S(a, b)               CHECK_GT_S(a, b)
	#define DCHECK_GE_S(a, b)               CHECK_GE_S(a, b)
#else
// Debug checks disabled:
	#define DCHECK_S(cond)                  CHECK_S(true || (cond))
	#define DCHECK_NOTNULL_S(x)             CHECK_S(true || (x) != nullptr)
	#define DCHECK_EQ_S(a, b)               CHECK_S(true || (a) == (b))
	#define DCHECK_NE_S(a, b)               CHECK_S(true || (a) != (b))
	#define DCHECK_LT_S(a, b)               CHECK_S(true || (a) &lt;  (b))
	#define DCHECK_LE_S(a, b)               CHECK_S(true || (a) &lt;= (b))
	#define DCHECK_GT_S(a, b)               CHECK_S(true || (a) &gt;  (b))
	#define DCHECK_GE_S(a, b)               CHECK_S(true || (a) &gt;= (b))
#endif

#if LOGURU_REPLACE_GLOG
	#undef LOG
	#undef VLOG
	#undef LOG_IF
	#undef VLOG_IF
	#undef CHECK
	#undef CHECK_NOTNULL
	#undef CHECK_EQ
	#undef CHECK_NE
	#undef CHECK_LT
	#undef CHECK_LE
	#undef CHECK_GT
	#undef CHECK_GE
	#undef DLOG
	#undef DVLOG
	#undef DLOG_IF
	#undef DVLOG_IF
	#undef DCHECK
	#undef DCHECK_NOTNULL
	#undef DCHECK_EQ
	#undef DCHECK_NE
	#undef DCHECK_LT
	#undef DCHECK_LE
	#undef DCHECK_GT
	#undef DCHECK_GE
	#undef VLOG_IS_ON

	#define LOG            LOG_S
	#define VLOG           VLOG_S
	#define LOG_IF         LOG_IF_S
	#define VLOG_IF        VLOG_IF_S
	#define CHECK(cond)    CHECK_S(!!(cond))
	#define CHECK_NOTNULL  CHECK_NOTNULL_S
	#define CHECK_EQ       CHECK_EQ_S
	#define CHECK_NE       CHECK_NE_S
	#define CHECK_LT       CHECK_LT_S
	#define CHECK_LE       CHECK_LE_S
	#define CHECK_GT       CHECK_GT_S
	#define CHECK_GE       CHECK_GE_S
	#define DLOG           DLOG_S
	#define DVLOG          DVLOG_S
	#define DLOG_IF        DLOG_IF_S
	#define DVLOG_IF       DVLOG_IF_S
	#define DCHECK         DCHECK_S
	#define DCHECK_NOTNULL DCHECK_NOTNULL_S
	#define DCHECK_EQ      DCHECK_EQ_S
	#define DCHECK_NE      DCHECK_NE_S
	#define DCHECK_LT      DCHECK_LT_S
	#define DCHECK_LE      DCHECK_LE_S
	#define DCHECK_GT      DCHECK_GT_S
	#define DCHECK_GE      DCHECK_GE_S
	#define VLOG_IS_ON(verbosity) ((verbosity) &lt;= loguru::current_verbosity_cutoff())

#endif // LOGURU_REPLACE_GLOG

#endif // LOGURU_WITH_STREAMS

#endif // LOGURU_HAS_DECLARED_STREAMS_HEADER
```

## `loguru.cpp`

```c&#43;&#43;
#ifndef _WIN32
// Disable all warnings from gcc/clang:
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored &#34;-Wpragmas&#34;

#pragma GCC diagnostic ignored &#34;-Wc&#43;&#43;98-compat&#34;
#pragma GCC diagnostic ignored &#34;-Wc&#43;&#43;98-compat-pedantic&#34;
#pragma GCC diagnostic ignored &#34;-Wexit-time-destructors&#34;
#pragma GCC diagnostic ignored &#34;-Wformat-nonliteral&#34;
#pragma GCC diagnostic ignored &#34;-Wglobal-constructors&#34;
#pragma GCC diagnostic ignored &#34;-Wgnu-zero-variadic-macro-arguments&#34;
#pragma GCC diagnostic ignored &#34;-Wmissing-prototypes&#34;
#pragma GCC diagnostic ignored &#34;-Wpadded&#34;
#pragma GCC diagnostic ignored &#34;-Wsign-compare&#34;
#pragma GCC diagnostic ignored &#34;-Wsign-conversion&#34;
#pragma GCC diagnostic ignored &#34;-Wunknown-pragmas&#34;
#pragma GCC diagnostic ignored &#34;-Wunused-macros&#34;
#pragma GCC diagnostic ignored &#34;-Wzero-as-null-pointer-constant&#34;
#else
#ifdef _MSC_VER
#pragma warning(push)
#pragma warning(disable:4018)
#endif // _MSC_VER
#endif
#define LOGURU_USE_FMTLIB 1
#include &#34;loguru.hpp&#34;

#ifndef LOGURU_HAS_BEEN_IMPLEMENTED
#define LOGURU_HAS_BEEN_IMPLEMENTED

// #define LOGURU_PREAMBLE_WIDTH (53 &#43; LOGURU_THREADNAME_WIDTH &#43; LOGURU_FILENAME_WIDTH)
#define LOGURU_PREAMBLE_WIDTH (57 &#43; LOGURU_THREADNAME_WIDTH &#43; LOGURU_FILENAME_WIDTH)

#undef min
#undef max

#include &lt;algorithm&gt;
#include &lt;atomic&gt;
#include &lt;chrono&gt;
#include &lt;cstdarg&gt;
#include &lt;cstdio&gt;
#include &lt;cstdlib&gt;
#include &lt;cstring&gt;
#include &lt;mutex&gt;
#include &lt;regex&gt;
#include &lt;string&gt;
#include &lt;thread&gt;
#include &lt;vector&gt;

#ifdef _WIN32
    #include &lt;direct.h&gt;

    #define localtime_r(a, b) localtime_s(b, a) // No localtime_r with MSVC, but arguments are swapped for localtime_s
#else
    #include &lt;signal.h&gt;
    #include &lt;sys/stat.h&gt; // mkdir
    #include &lt;unistd.h&gt;   // STDERR_FILENO
#endif

#ifdef __linux__
    #include &lt;linux/limits.h&gt; // PATH_MAX
#elif !defined(_WIN32)
    #include &lt;limits.h&gt; // PATH_MAX
#endif

#ifndef PATH_MAX
    #define PATH_MAX 1024
#endif

#ifdef __APPLE__
    #include &#34;TargetConditionals.h&#34;
#endif

// TODO: use defined(_POSIX_VERSION) for some of these things?

#if defined(_WIN32) || defined(__CYGWIN__)
    #define LOGURU_PTHREADS    0
    #define LOGURU_WINTHREADS  1
    #ifndef LOGURU_STACKTRACES
        #define LOGURU_STACKTRACES 0
    #endif
#elif defined(__rtems__) || defined(__ANDROID__) || defined(__FreeBSD__)
    #define LOGURU_PTHREADS    1
    #define LOGURU_WINTHREADS  0
    #ifndef LOGURU_STACKTRACES
        #define LOGURU_STACKTRACES 0
    #endif
#else
    #define LOGURU_PTHREADS    1
    #define LOGURU_WINTHREADS  0
    #ifndef LOGURU_STACKTRACES
        #define LOGURU_STACKTRACES 1
    #endif
#endif

#if LOGURU_STACKTRACES
    #include &lt;cxxabi.h&gt;    // for __cxa_demangle
    #include &lt;dlfcn.h&gt;     // for dladdr
    #include &lt;execinfo.h&gt;  // for backtrace
#endif // LOGURU_STACKTRACES

#if LOGURU_PTHREADS
    #include &lt;pthread.h&gt;
    #if defined(__FreeBSD__)
        #include &lt;pthread_np.h&gt;
        #include &lt;sys/thr.h&gt;
    #elif defined(__OpenBSD__)
        #include &lt;pthread_np.h&gt;
    #endif

    #ifdef __linux__
        /* On Linux, the default thread name is the same as the name of the binary.
           Additionally, all new threads inherit the name of the thread it got forked from.
           For this reason, Loguru use the pthread Thread Local Storage
           for storing thread names on Linux. */
        #define LOGURU_PTLS_NAMES 1
    #endif
#endif

#if LOGURU_WINTHREADS
    #ifndef _WIN32_WINNT
        #define _WIN32_WINNT 0x0502
    #endif
    #define WIN32_LEAN_AND_MEAN
    #define NOMINMAX
    #include &lt;windows.h&gt;
#endif

#ifndef LOGURU_PTLS_NAMES
   #define LOGURU_PTLS_NAMES 0
#endif


namespace loguru
{
    using namespace std::chrono;

#if LOGURU_WITH_FILEABS
    struct FileAbs
    {
        char path[PATH_MAX];
        char mode_str[4];
        Verbosity verbosity;
        struct stat st;
        FILE* fp;
        bool is_reopening = false; // to prevent recursive call in file_reopen.
        decltype(steady_clock::now()) last_check_time = steady_clock::now();
    };
#else
    typedef FILE* FileAbs;
#endif

    struct Callback
    {
        std::string     id;
        log_handler_t   callback;
        void*           user_data;
        Verbosity       verbosity; // Does not change!
        close_handler_t close;
        flush_handler_t flush;
        unsigned        indentation;
    };

    using CallbackVec = std::vector&lt;Callback&gt;;

    using StringPair     = std::pair&lt;std::string, std::string&gt;;
    using StringPairList = std::vector&lt;StringPair&gt;;

    const auto s_start_time = steady_clock::now();

    Verbosity g_stderr_verbosity  = Verbosity_0;
    bool      g_colorlogtostderr  = true;
    unsigned  g_flush_interval_ms = 0;
    bool      g_preamble_header   = true;
    bool      g_preamble          = true;

    Verbosity g_internal_verbosity = Verbosity_0;

    // Preamble details
    bool      g_preamble_date     = true;
    bool      g_preamble_time     = true;
    bool      g_preamble_uptime   = true;
    bool      g_preamble_thread   = true;
    bool      g_preamble_file     = true;
    bool      g_preamble_verbose  = true;
    bool      g_preamble_pipe     = true;

    static std::recursive_mutex  s_mutex;
    static Verbosity             s_max_out_verbosity = Verbosity_OFF;
    static std::string           s_argv0_filename;
    static std::string           s_arguments;
    static char                  s_current_dir[PATH_MAX];
    static CallbackVec           s_callbacks;
    static fatal_handler_t       s_fatal_handler   = nullptr;
    static verbosity_to_name_t   s_verbosity_to_name_callback = nullptr;
    static name_to_verbosity_t   s_name_to_verbosity_callback = nullptr;
    static StringPairList        s_user_stack_cleanups;
    static bool                  s_strip_file_path = true;
    static std::atomic&lt;unsigned&gt; s_stderr_indentation { 0 };

    // For periodic flushing:
    static std::thread* s_flush_thread   = nullptr;
    static bool         s_needs_flushing = false;

    static const bool s_terminal_has_color = [](){
        #ifdef _WIN32
            #ifndef ENABLE_VIRTUAL_TERMINAL_PROCESSING
            #define ENABLE_VIRTUAL_TERMINAL_PROCESSING  0x0004
            #endif

            HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
            if (hOut != INVALID_HANDLE_VALUE) {
                DWORD dwMode = 0;
                GetConsoleMode(hOut, &amp;dwMode);
                dwMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
                return SetConsoleMode(hOut, dwMode) != 0;
            }
            return false;
        #else
            if (!isatty(STDERR_FILENO)) {
                return false;
            }
            if (const char* term = getenv(&#34;TERM&#34;)) {
                return 0 == strcmp(term, &#34;cygwin&#34;)
                    || 0 == strcmp(term, &#34;linux&#34;)
                    || 0 == strcmp(term, &#34;rxvt-unicode-256color&#34;)
                    || 0 == strcmp(term, &#34;screen&#34;)
                    || 0 == strcmp(term, &#34;screen-256color&#34;)
                    || 0 == strcmp(term, &#34;screen.xterm-256color&#34;)
                    || 0 == strcmp(term, &#34;tmux-256color&#34;)
                    || 0 == strcmp(term, &#34;xterm&#34;)
                    || 0 == strcmp(term, &#34;xterm-256color&#34;)
                    || 0 == strcmp(term, &#34;xterm-termite&#34;)
                    || 0 == strcmp(term, &#34;xterm-color&#34;);
            } else {
                return false;
            }
        #endif
    }();

    static void print_preamble_header(char* out_buff, size_t out_buff_size);

    #if LOGURU_PTLS_NAMES
        static pthread_once_t s_pthread_key_once = PTHREAD_ONCE_INIT;
        static pthread_key_t  s_pthread_key_name;

        void make_pthread_key_name()
        {
            (void)pthread_key_create(&amp;s_pthread_key_name, free);
        }
    #endif

    // ------------------------------------------------------------------------------
    // Colors

    bool terminal_has_color() { return s_terminal_has_color; }

    // Colors

#ifdef _WIN32
#define VTSEQ(ID) (&#34;\x1b[1;&#34; #ID &#34;m&#34;)
#else
#define VTSEQ(ID) (&#34;\x1b[&#34; #ID &#34;m&#34;)
#endif

    const char* terminal_black()      { return s_terminal_has_color ? VTSEQ(30) : &#34;&#34;; }
    const char* terminal_red()        { return s_terminal_has_color ? VTSEQ(31) : &#34;&#34;; }
    const char* terminal_green()      { return s_terminal_has_color ? VTSEQ(32) : &#34;&#34;; }
    const char* terminal_yellow()     { return s_terminal_has_color ? VTSEQ(33) : &#34;&#34;; }
    const char* terminal_blue()       { return s_terminal_has_color ? VTSEQ(34) : &#34;&#34;; }
    const char* terminal_purple()     { return s_terminal_has_color ? VTSEQ(35) : &#34;&#34;; }
    const char* terminal_cyan()       { return s_terminal_has_color ? VTSEQ(36) : &#34;&#34;; }
    const char* terminal_light_gray() { return s_terminal_has_color ? VTSEQ(37) : &#34;&#34;; }
    const char* terminal_white()      { return s_terminal_has_color ? VTSEQ(37) : &#34;&#34;; }
    const char* terminal_light_red()  { return s_terminal_has_color ? VTSEQ(91) : &#34;&#34;; }
    const char* terminal_dim()        { return s_terminal_has_color ? VTSEQ(2)  : &#34;&#34;; }

    // Formating
    const char* terminal_bold()       { return s_terminal_has_color ? VTSEQ(1) : &#34;&#34;; }
    const char* terminal_underline()  { return s_terminal_has_color ? VTSEQ(4) : &#34;&#34;; }

    // You should end each line with this!
    const char* terminal_reset()      { return s_terminal_has_color ? VTSEQ(0) : &#34;&#34;; }

    // ------------------------------------------------------------------------------
#if LOGURU_WITH_FILEABS
    void file_reopen(void* user_data);
    inline FILE* to_file(void* user_data) { return reinterpret_cast&lt;FileAbs*&gt;(user_data)-&gt;fp; }
#else
    inline FILE* to_file(void* user_data) { return reinterpret_cast&lt;FILE*&gt;(user_data); }
#endif

    void file_log(void* user_data, const Message&amp; message)
    {
#if LOGURU_WITH_FILEABS
        FileAbs* file_abs = reinterpret_cast&lt;FileAbs*&gt;(user_data);
        if (file_abs-&gt;is_reopening) {
            return;
        }
        // It is better checking file change every minute/hour/day,
        // instead of doing this every time we log.
        // Here check_interval is set to zero to enable checking every time;
        const auto check_interval = seconds(0);
        if (duration_cast&lt;seconds&gt;(steady_clock::now() - file_abs-&gt;last_check_time) &gt; check_interval) {
            file_abs-&gt;last_check_time = steady_clock::now();
            file_reopen(user_data);
        }
        FILE* file = to_file(user_data);
        if (!file) {
            return;
        }
#else
        FILE* file = to_file(user_data);
#endif
        fprintf(file, &#34;%s%s%s%s\n&#34;,
            message.preamble, message.indentation, message.prefix, message.message);
        if (g_flush_interval_ms == 0) {
            fflush(file);
        }
    }

    void file_close(void* user_data)
    {
        FILE* file = to_file(user_data);
        if (file) {
            fclose(file);
        }
#if LOGURU_WITH_FILEABS
        delete reinterpret_cast&lt;FileAbs*&gt;(user_data);
#endif
    }

    void file_flush(void* user_data)
    {
        FILE* file = to_file(user_data);
        fflush(file);
    }

#if LOGURU_WITH_FILEABS
    void file_reopen(void* user_data)
    {
        FileAbs * file_abs = reinterpret_cast&lt;FileAbs*&gt;(user_data);
        struct stat st;
        int ret;
        if (!file_abs-&gt;fp || (ret = stat(file_abs-&gt;path, &amp;st)) == -1 || (st.st_ino != file_abs-&gt;st.st_ino)) {
            file_abs-&gt;is_reopening = true;
            if (file_abs-&gt;fp) {
                fclose(file_abs-&gt;fp);
            }
            if (!file_abs-&gt;fp) {
                VLOG_F(g_internal_verbosity, &#34;Reopening file &#39;&#34; LOGURU_FMT(s) &#34;&#39; due to previous error&#34;, file_abs-&gt;path);
            }
            else if (ret &lt; 0) {
                const auto why = errno_as_text();
                VLOG_F(g_internal_verbosity, &#34;Reopening file &#39;&#34; LOGURU_FMT(s) &#34;&#39; due to &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, file_abs-&gt;path, why.c_str());
            } else {
                VLOG_F(g_internal_verbosity, &#34;Reopening file &#39;&#34; LOGURU_FMT(s) &#34;&#39; due to file changed&#34;, file_abs-&gt;path);
            }
            // try reopen current file.
            if (!create_directories(file_abs-&gt;path)) {
                LOG_F(ERROR, &#34;Failed to create directories to &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, file_abs-&gt;path);
            }
            file_abs-&gt;fp = fopen(file_abs-&gt;path, file_abs-&gt;mode_str);
            if (!file_abs-&gt;fp) {
                LOG_F(ERROR, &#34;Failed to open &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, file_abs-&gt;path);
            } else {
                stat(file_abs-&gt;path, &amp;file_abs-&gt;st);
            }
            file_abs-&gt;is_reopening = false;
        }
    }
#endif
    // ------------------------------------------------------------------------------

    // Helpers:

    Text::~Text() { free(_str); }

#if LOGURU_USE_FMTLIB
    Text vtextprintf(const char* format, fmt::format_args args)
    {
        return Text(STRDUP(fmt::vformat(format, args).c_str()));
    }
#else
    LOGURU_PRINTF_LIKE(1, 0)
    static Text vtextprintf(const char* format, va_list vlist)
    {
#ifdef _WIN32
        int bytes_needed = _vscprintf(format, vlist);
        CHECK_F(bytes_needed &gt;= 0, &#34;Bad string format: &#39;%s&#39;&#34;, format);
        char* buff = (char*)malloc(bytes_needed&#43;1);
        vsnprintf(buff, bytes_needed&#43;1, format, vlist);
        return Text(buff);
#else
        char* buff = nullptr;
        int result = vasprintf(&amp;buff, format, vlist);
        CHECK_F(result &gt;= 0, &#34;Bad string format: &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, format);
        return Text(buff);
#endif
    }

    Text textprintf(const char* format, ...)
    {
        va_list vlist;
        va_start(vlist, format);
        auto result = vtextprintf(format, vlist);
        va_end(vlist);
        return result;
    }
#endif

    // Overloaded for variadic template matching.
    Text textprintf()
    {
        return Text(static_cast&lt;char*&gt;(calloc(1, 1)));
    }

    static const char* indentation(unsigned depth)
    {
        static const char buff[] =
        &#34;.   .   .   .   .   .   .   .   .   .   &#34; &#34;.   .   .   .   .   .   .   .   .   .   &#34;
        &#34;.   .   .   .   .   .   .   .   .   .   &#34; &#34;.   .   .   .   .   .   .   .   .   .   &#34;
        &#34;.   .   .   .   .   .   .   .   .   .   &#34; &#34;.   .   .   .   .   .   .   .   .   .   &#34;
        &#34;.   .   .   .   .   .   .   .   .   .   &#34; &#34;.   .   .   .   .   .   .   .   .   .   &#34;
        &#34;.   .   .   .   .   .   .   .   .   .   &#34; &#34;.   .   .   .   .   .   .   .   .   .   &#34;;
        static const size_t INDENTATION_WIDTH = 4;
        static const size_t NUM_INDENTATIONS = (sizeof(buff) - 1) / INDENTATION_WIDTH;
        depth = std::min&lt;unsigned&gt;(depth, NUM_INDENTATIONS);
        return buff &#43; INDENTATION_WIDTH * (NUM_INDENTATIONS - depth);
    }

    static void parse_args(int&amp; argc, char* argv[], const char* verbosity_flag)
    {
        int arg_dest = 1;
        int out_argc = argc;

        for (int arg_it = 1; arg_it &lt; argc; &#43;&#43;arg_it) {
            auto cmd = argv[arg_it];
            auto arg_len = strlen(verbosity_flag);
            if (strncmp(cmd, verbosity_flag, arg_len) == 0 &amp;&amp; !std::isalpha(cmd[arg_len], std::locale(&#34;&#34;))) {
                out_argc -= 1;
                auto value_str = cmd &#43; arg_len;
                if (value_str[0] == &#39;\0&#39;) {
                    // Value in separate argument
                    arg_it &#43;= 1;
                    CHECK_LT_F(arg_it, argc, &#34;Missing verbosiy level after &#34; LOGURU_FMT(s) &#34;&#34;, verbosity_flag);
                    value_str = argv[arg_it];
                    out_argc -= 1;
                }
                if (*value_str == &#39;=&#39;) { value_str &#43;= 1; }

                auto req_verbosity = get_verbosity_from_name(value_str);
                if (req_verbosity != Verbosity_INVALID) {
                    g_stderr_verbosity = req_verbosity;
                } else {
                    char* end = 0;
                    g_stderr_verbosity = static_cast&lt;int&gt;(strtol(value_str, &amp;end, 10));
                    CHECK_F(end &amp;&amp; *end == &#39;\0&#39;,
                        &#34;Invalid verbosity. Expected integer, INFO, WARNING, ERROR or OFF, got &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, value_str);
                }
            } else {
                argv[arg_dest&#43;&#43;] = argv[arg_it];
            }
        }

        argc = out_argc;
        argv[argc] = nullptr;
    }

    static long long now_ns()
    {
        return duration_cast&lt;nanoseconds&gt;(high_resolution_clock::now().time_since_epoch()).count();
    }

    // Returns the part of the path after the last / or \ (if any).
    const char* filename(const char* path)
    {
        for (auto ptr = path; *ptr; &#43;&#43;ptr) {
            if (*ptr == &#39;/&#39; || *ptr == &#39;\\&#39;) {
                path = ptr &#43; 1;
            }
        }
        return path;
    }

    // ------------------------------------------------------------------------------

    static void on_atexit()
    {
        VLOG_F(g_internal_verbosity, &#34;atexit&#34;);
        flush();
    }

    static void install_signal_handlers(bool unsafe_signal_handler);

    static void write_hex_digit(std::string&amp; out, unsigned num)
    {
        DCHECK_LT_F(num, 16u);
        if (num &lt; 10u) { out.push_back(char(&#39;0&#39; &#43; num)); }
        else { out.push_back(char(&#39;A&#39; &#43; num - 10)); }
    }

    static void write_hex_byte(std::string&amp; out, uint8_t n)
    {
        write_hex_digit(out, n &gt;&gt; 4u);
        write_hex_digit(out, n &amp; 0x0f);
    }

    static void escape(std::string&amp; out, const std::string&amp; str)
    {
        for (char c : str) {
            /**/ if (c == &#39;\a&#39;) { out &#43;= &#34;\\a&#34;;  }
            else if (c == &#39;\b&#39;) { out &#43;= &#34;\\b&#34;;  }
            else if (c == &#39;\f&#39;) { out &#43;= &#34;\\f&#34;;  }
            else if (c == &#39;\n&#39;) { out &#43;= &#34;\\n&#34;;  }
            else if (c == &#39;\r&#39;) { out &#43;= &#34;\\r&#34;;  }
            else if (c == &#39;\t&#39;) { out &#43;= &#34;\\t&#34;;  }
            else if (c == &#39;\v&#39;) { out &#43;= &#34;\\v&#34;;  }
            else if (c == &#39;\\&#39;) { out &#43;= &#34;\\\\&#34;; }
            else if (c == &#39;\&#39;&#39;) { out &#43;= &#34;\\\&#39;&#34;; }
            else if (c == &#39;\&#34;&#39;) { out &#43;= &#34;\\\&#34;&#34;; }
            else if (c == &#39; &#39;)  { out &#43;= &#34;\\ &#34;;  }
            else if (0 &lt;= c &amp;&amp; c &lt; 0x20) { // ASCI control character:
            // else if (c &lt; 0x20 || c != (c &amp; 127)) { // ASCII control character or UTF-8:
                out &#43;= &#34;\\x&#34;;
                write_hex_byte(out, static_cast&lt;uint8_t&gt;(c));
            } else { out &#43;= c; }
        }
    }

    Text errno_as_text()
    {
        char buff[256];
    #if defined(__GLIBC__) &amp;&amp; defined(_GNU_SOURCE)
        // GNU Version
        return Text(STRDUP(strerror_r(errno, buff, sizeof(buff))));
    #elif defined(__APPLE__) || _POSIX_C_SOURCE &gt;= 200112L
        // XSI Version
        strerror_r(errno, buff, sizeof(buff));
        return Text(strdup(buff));
    #elif defined(_WIN32)
        strerror_s(buff, sizeof(buff), errno);
        return Text(STRDUP(buff));
    #else
        // Not thread-safe.
        return Text(STRDUP(strerror(errno)));
    #endif
    }

    void init(int&amp; argc, char* argv[], const Options&amp; options)
    {
        CHECK_GT_F(argc,       0,       &#34;Expected proper argc/argv&#34;);
        CHECK_EQ_F(argv[argc], nullptr, &#34;Expected proper argc/argv&#34;);

        s_argv0_filename = filename(argv[0]);

        #ifdef _WIN32
            #define getcwd _getcwd
        #endif

        if (!getcwd(s_current_dir, sizeof(s_current_dir))) {
            const auto error_text = errno_as_text();
            LOG_F(WARNING, &#34;Failed to get current working directory: &#34; LOGURU_FMT(s) &#34;&#34;, error_text.c_str());
        }

        s_arguments = &#34;&#34;;
        for (int i = 0; i &lt; argc; &#43;&#43;i) {
            escape(s_arguments, argv[i]);
            if (i &#43; 1 &lt; argc) {
                s_arguments &#43;= &#34; &#34;;
            }
        }

        if (options.verbosity_flag) {
            parse_args(argc, argv, options.verbosity_flag);
        }

        if (const auto main_thread_name = options.main_thread_name) {
            #if LOGURU_PTLS_NAMES || LOGURU_WINTHREADS
                set_thread_name(main_thread_name);
            #elif LOGURU_PTHREADS
                char old_thread_name[16] = {0};
                auto this_thread = pthread_self();
                #if defined(__APPLE__) || defined(__linux__)
                    pthread_getname_np(this_thread, old_thread_name, sizeof(old_thread_name));
                #endif
                if (old_thread_name[0] == 0) {
                    #ifdef __APPLE__
                        pthread_setname_np(main_thread_name);
                    #elif defined(__FreeBSD__) || defined(__OpenBSD__)
                        pthread_set_name_np(this_thread, main_thread_name);
                    #elif defined(__linux__)
                        pthread_setname_np(this_thread, main_thread_name);
                    #endif
                }
            #endif // LOGURU_PTHREADS
        }

        if (g_stderr_verbosity &gt;= Verbosity_INFO) {
            if (g_preamble_header) {
                char preamble_explain[LOGURU_PREAMBLE_WIDTH];
                print_preamble_header(preamble_explain, sizeof(preamble_explain));
                if (g_colorlogtostderr &amp;&amp; s_terminal_has_color) {
                    fprintf(stderr, &#34;%s%s%s\n&#34;, terminal_reset(), terminal_dim(), preamble_explain);
                } else {
                    fprintf(stderr, &#34;%s\n&#34;, preamble_explain);
                }
            }
            fflush(stderr);
        }
        VLOG_F(g_internal_verbosity, &#34;arguments: &#34; LOGURU_FMT(s) &#34;&#34;, s_arguments.c_str());
        if (strlen(s_current_dir) != 0)
        {
            VLOG_F(g_internal_verbosity, &#34;Current dir: &#34; LOGURU_FMT(s) &#34;&#34;, s_current_dir);
        }
        VLOG_F(g_internal_verbosity, &#34;stderr verbosity: &#34; LOGURU_FMT(d) &#34;&#34;, g_stderr_verbosity);
        VLOG_F(g_internal_verbosity, &#34;-----------------------------------&#34;);

        install_signal_handlers(options.unsafe_signal_handler);

        atexit(on_atexit);
    }

    void shutdown()
    {
        VLOG_F(g_internal_verbosity, &#34;loguru::shutdown()&#34;);
        remove_all_callbacks();
        set_fatal_handler(nullptr);
        set_verbosity_to_name_callback(nullptr);
        set_name_to_verbosity_callback(nullptr);
    }

    void write_date_time(char* buff, size_t buff_size)
    {
        auto now = system_clock::now();
        long long ms_since_epoch = duration_cast&lt;microseconds&gt;(now.time_since_epoch()).count();
        time_t sec_since_epoch = time_t(ms_since_epoch / 1000000);
        tm time_info;
        localtime_r(&amp;sec_since_epoch, &amp;time_info);
        snprintf(buff, buff_size, &#34;%04d%02d%02d_%02d%02d%02d.%06lld&#34;,
            1900 &#43; time_info.tm_year, 1 &#43; time_info.tm_mon, time_info.tm_mday,
            time_info.tm_hour, time_info.tm_min, time_info.tm_sec, ms_since_epoch % 1000000);
    }

    const char* argv0_filename()
    {
        return s_argv0_filename.c_str();
    }

    const char* arguments()
    {
        return s_arguments.c_str();
    }

    const char* current_dir()
    {
        return s_current_dir;
    }

    const char* home_dir()
    {
        #ifdef _WIN32
            char* user_profile;
            size_t len;
            errno_t err = _dupenv_s(&amp;user_profile, &amp;len, &#34;USERPROFILE&#34;);
            CHECK_F(err != 0, &#34;Missing USERPROFILE&#34;);
            return user_profile;
        #else // _WIN32
            auto home = getenv(&#34;HOME&#34;);
            CHECK_F(home != nullptr, &#34;Missing HOME&#34;);
            return home;
        #endif // _WIN32
    }

    void suggest_log_path(const char* prefix, char* buff, unsigned buff_size)
    {
        if (prefix[0] == &#39;~&#39;) {
            snprintf(buff, buff_size - 1, &#34;%s%s&#34;, home_dir(), prefix &#43; 1);
        } else {
            snprintf(buff, buff_size - 1, &#34;%s&#34;, prefix);
        }

        // Check for terminating /
        size_t n = strlen(buff);
        if (n != 0) {
            if (buff[n - 1] != &#39;/&#39;) {
                CHECK_F(n &#43; 2 &lt; buff_size, &#34;Filename buffer too small&#34;);
                buff[n] = &#39;/&#39;;
                buff[n &#43; 1] = &#39;\0&#39;;
            }
        }

    #ifdef _WIN32
        strncat_s(buff, buff_size - strlen(buff) - 1, s_argv0_filename.c_str(), buff_size - strlen(buff) - 1);
        strncat_s(buff, buff_size - strlen(buff) - 1, &#34;/&#34;,                      buff_size - strlen(buff) - 1);
        write_date_time(buff &#43; strlen(buff),    buff_size - strlen(buff));
        strncat_s(buff, buff_size - strlen(buff) - 1, &#34;.log&#34;,                   buff_size - strlen(buff) - 1);
    #else
        strncat(buff, s_argv0_filename.c_str(), buff_size - strlen(buff) - 1);
        strncat(buff, &#34;/&#34;, buff_size - strlen(buff) - 1);
        write_date_time(buff &#43; strlen(buff), buff_size - strlen(buff));
        strncat(buff, &#34;.log&#34;, buff_size - strlen(buff) - 1);
    #endif
    }

    bool create_directories(const char* file_path_const)
    {
        CHECK_F(file_path_const &amp;&amp; *file_path_const);
        char* file_path = STRDUP(file_path_const);
        for (char* p = strchr(file_path &#43; 1, &#39;/&#39;); p; p = strchr(p &#43; 1, &#39;/&#39;)) {
            *p = &#39;\0&#39;;

    #ifdef _WIN32
            if (_mkdir(file_path) == -1) {
    #else
            if (mkdir(file_path, 0755) == -1) {
    #endif
                if (errno != EEXIST) {
                    LOG_F(ERROR, &#34;Failed to create directory &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, file_path);
                    LOG_IF_F(ERROR, errno == EACCES,       &#34;EACCES&#34;);
                    LOG_IF_F(ERROR, errno == ENAMETOOLONG, &#34;ENAMETOOLONG&#34;);
                    LOG_IF_F(ERROR, errno == ENOENT,       &#34;ENOENT&#34;);
                    LOG_IF_F(ERROR, errno == ENOTDIR,      &#34;ENOTDIR&#34;);
                    LOG_IF_F(ERROR, errno == ELOOP,        &#34;ELOOP&#34;);

                    *p = &#39;/&#39;;
                    free(file_path);
                    return false;
                }
            }
            *p = &#39;/&#39;;
        }
        free(file_path);
        return true;
    }
    bool add_file(const char* path_in, FileMode mode, Verbosity verbosity)
    {
        char path[PATH_MAX];
        if (path_in[0] == &#39;~&#39;) {
            snprintf(path, sizeof(path) - 1, &#34;%s%s&#34;, home_dir(), path_in &#43; 1);
        } else {
            snprintf(path, sizeof(path) - 1, &#34;%s&#34;, path_in);
        }

        if (!create_directories(path)) {
            LOG_F(ERROR, &#34;Failed to create directories to &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, path);
        }

        const char* mode_str = (mode == FileMode::Truncate ? &#34;w&#34; : &#34;a&#34;);
        FILE* file;
    #ifdef _WIN32
        errno_t file_error = fopen_s(&amp;file, path, mode_str);
        if (file_error) {
    #else
        file = fopen(path, mode_str);
        if (!file) {
    #endif
            LOG_F(ERROR, &#34;Failed to open &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, path);
            return false;
        }
#if LOGURU_WITH_FILEABS
        FileAbs* file_abs = new FileAbs(); // this is deleted in file_close;
        snprintf(file_abs-&gt;path, sizeof(file_abs-&gt;path) - 1, &#34;%s&#34;, path);
        snprintf(file_abs-&gt;mode_str, sizeof(file_abs-&gt;mode_str) - 1, &#34;%s&#34;, mode_str);
        stat(file_abs-&gt;path, &amp;file_abs-&gt;st);
        file_abs-&gt;fp = file;
        file_abs-&gt;verbosity = verbosity;
        add_callback(path_in, file_log, file_abs, verbosity, file_close, file_flush);
#else
        add_callback(path_in, file_log, file, verbosity, file_close, file_flush);
#endif

        if (mode == FileMode::Append) {
            fprintf(file, &#34;\n\n\n\n\n&#34;);
        }
        if (!s_arguments.empty()) {
            fprintf(file, &#34;arguments: %s\n&#34;, s_arguments.c_str());
        }
        if (strlen(s_current_dir) != 0) {
            fprintf(file, &#34;Current dir: %s\n&#34;, s_current_dir);
        }
        fprintf(file, &#34;File verbosity level: %d\n&#34;, verbosity);
        if (g_preamble_header) {
            char preamble_explain[LOGURU_PREAMBLE_WIDTH];
            print_preamble_header(preamble_explain, sizeof(preamble_explain));
            fprintf(file, &#34;%s\n&#34;, preamble_explain);
        }
        fflush(file);

        VLOG_F(g_internal_verbosity, &#34;Logging to &#39;&#34; LOGURU_FMT(s) &#34;&#39;, mode: &#39;&#34; LOGURU_FMT(s) &#34;&#39;, verbosity: &#34; LOGURU_FMT(d) &#34;&#34;, path, mode_str, verbosity);
        return true;
    }

    // Will be called right before abort().
    void set_fatal_handler(fatal_handler_t handler)
    {
        s_fatal_handler = handler;
    }

    fatal_handler_t get_fatal_handler()
    {
        return s_fatal_handler;
    }

    void set_verbosity_to_name_callback(verbosity_to_name_t callback)
    {
        s_verbosity_to_name_callback = callback;
    }

    void set_name_to_verbosity_callback(name_to_verbosity_t callback)
    {
        s_name_to_verbosity_callback = callback;
    }

    void add_stack_cleanup(const char* find_this, const char* replace_with_this)
    {
        if (strlen(find_this) &lt;= strlen(replace_with_this)) {
            LOG_F(WARNING, &#34;add_stack_cleanup: the replacement should be shorter than the pattern!&#34;);
            return;
        }

        s_user_stack_cleanups.push_back(StringPair(find_this, replace_with_this));
    }

    static void on_callback_change()
    {
        s_max_out_verbosity = Verbosity_OFF;
        for (const auto&amp; callback : s_callbacks) {
            s_max_out_verbosity = std::max(s_max_out_verbosity, callback.verbosity);
        }
    }

    void add_callback(
        const char*     id,
        log_handler_t   callback,
        void*           user_data,
        Verbosity       verbosity,
        close_handler_t on_close,
        flush_handler_t on_flush)
    {
        std::lock_guard&lt;std::recursive_mutex&gt; lock(s_mutex);
        s_callbacks.push_back(Callback{id, callback, user_data, verbosity, on_close, on_flush, 0});
        on_callback_change();
    }

    // Returns a custom verbosity name if one is available, or nullptr.
    // See also set_verbosity_to_name_callback.
    const char* get_verbosity_name(Verbosity verbosity)
    {
        auto name = s_verbosity_to_name_callback
                ? (*s_verbosity_to_name_callback)(verbosity)
                : nullptr;

        // Use standard replacements if callback fails:
        if (!name)
        {
            if (verbosity &lt;= Verbosity_FATAL) {
                name = &#34;FATL&#34;;
            } else if (verbosity == Verbosity_ERROR) {
                name = &#34;ERR&#34;;
            } else if (verbosity == Verbosity_WARNING) {
                name = &#34;WARN&#34;;
            } else if (verbosity == Verbosity_INFO) {
                name = &#34;INFO&#34;;
            }
        }

        return name;
    }

    // Returns Verbosity_INVALID if the name is not found.
    // See also set_name_to_verbosity_callback.
    Verbosity get_verbosity_from_name(const char* name)
    {
        auto verbosity = s_name_to_verbosity_callback
                ? (*s_name_to_verbosity_callback)(name)
                : Verbosity_INVALID;

        // Use standard replacements if callback fails:
        if (verbosity == Verbosity_INVALID) {
            if (strcmp(name, &#34;OFF&#34;) == 0) {
                verbosity = Verbosity_OFF;
            } else if (strcmp(name, &#34;INFO&#34;) == 0) {
                verbosity = Verbosity_INFO;
            } else if (strcmp(name, &#34;WARNING&#34;) == 0) {
                verbosity = Verbosity_WARNING;
            } else if (strcmp(name, &#34;ERROR&#34;) == 0) {
                verbosity = Verbosity_ERROR;
            } else if (strcmp(name, &#34;FATAL&#34;) == 0) {
                verbosity = Verbosity_FATAL;
            }
        }

        return verbosity;
    }

    bool remove_callback(const char* id)
    {
        std::lock_guard&lt;std::recursive_mutex&gt; lock(s_mutex);
        auto it = std::find_if(begin(s_callbacks), end(s_callbacks), [&amp;](const Callback&amp; c) { return c.id == id; });
        if (it != s_callbacks.end()) {
            if (it-&gt;close) { it-&gt;close(it-&gt;user_data); }
            s_callbacks.erase(it);
            on_callback_change();
            return true;
        } else {
            LOG_F(ERROR, &#34;Failed to locate callback with id &#39;&#34; LOGURU_FMT(s) &#34;&#39;&#34;, id);
            return false;
        }
    }

    void remove_all_callbacks()
    {
        std::lock_guard&lt;std::recursive_mutex&gt; lock(s_mutex);
        for (auto&amp; callback : s_callbacks) {
            if (callback.close) {
                callback.close(callback.user_data);
            }
        }
        s_callbacks.clear();
        on_callback_change();
    }

    // Returns the maximum of g_stderr_verbosity and all file/custom outputs.
    Verbosity current_verbosity_cutoff()
    {
        return g_stderr_verbosity &gt; s_max_out_verbosity ?
               g_stderr_verbosity : s_max_out_verbosity;
    }

#if LOGURU_WINTHREADS
    char* get_thread_name_win32()
    {
        __declspec( thread ) static char thread_name[LOGURU_THREADNAME_WIDTH &#43; 1] = {0};
        return &amp;thread_name[0];
    }
#endif // LOGURU_WINTHREADS

    void set_thread_name(const char* name)
    {
        #if LOGURU_PTLS_NAMES
            (void)pthread_once(&amp;s_pthread_key_once, make_pthread_key_name);
            (void)pthread_setspecific(s_pthread_key_name, STRDUP(name));

        #elif LOGURU_PTHREADS
            #ifdef __APPLE__
                pthread_setname_np(name);
            #elif defined(__FreeBSD__) || defined(__OpenBSD__)
                pthread_set_name_np(pthread_self(), name);
            #elif defined(__linux__)
                pthread_setname_np(pthread_self(), name);
            #endif
        #elif LOGURU_WINTHREADS
            strncpy_s(get_thread_name_win32(), LOGURU_THREADNAME_WIDTH &#43; 1, name, _TRUNCATE);
        #else // LOGURU_PTHREADS
            (void)name;
        #endif // LOGURU_PTHREADS
    }

#if LOGURU_PTLS_NAMES
    const char* get_thread_name_ptls()
    {
        (void)pthread_once(&amp;s_pthread_key_once, make_pthread_key_name);
        return static_cast&lt;const char*&gt;(pthread_getspecific(s_pthread_key_name));
    }
#endif // LOGURU_PTLS_NAMES

    void get_thread_name(char* buffer, unsigned long long length, bool right_align_hext_id)
    {
#ifdef _WIN32
        (void)right_align_hext_id;
#endif
        CHECK_NE_F(length, 0u, &#34;Zero length buffer in get_thread_name&#34;);
        CHECK_NOTNULL_F(buffer, &#34;nullptr in get_thread_name&#34;);
#if LOGURU_PTHREADS
        auto thread = pthread_self();
        #if LOGURU_PTLS_NAMES
            if (const char* name = get_thread_name_ptls()) {
                snprintf(buffer, length, &#34;%s&#34;, name);
            } else {
                buffer[0] = 0;
            }
        #elif defined(__APPLE__) || defined(__linux__)
            pthread_getname_np(thread, buffer, length);
        #else
            buffer[0] = 0;
        #endif

        if (buffer[0] == 0) {
            #ifdef __APPLE__
                uint64_t thread_id;
                pthread_threadid_np(thread, &amp;thread_id);
            #elif defined(__FreeBSD__)
                long thread_id;
                (void)thr_self(&amp;thread_id);
            #elif defined(__OpenBSD__)
                unsigned thread_id = -1;
            #else
                uint64_t thread_id = thread;
            #endif
            if (right_align_hext_id) {
                snprintf(buffer, length, &#34;%*X&#34;, static_cast&lt;int&gt;(length - 1), static_cast&lt;unsigned&gt;(thread_id));
            } else {
                snprintf(buffer, length, &#34;%X&#34;, static_cast&lt;unsigned&gt;(thread_id));
            }
        }
#elif LOGURU_WINTHREADS
        if (const char* name = get_thread_name_win32()) {
            snprintf(buffer, (size_t)length, &#34;%s&#34;, name);
        } else {
            buffer[0] = 0;
        }
#else // !LOGURU_WINTHREADS &amp;&amp; !LOGURU_WINTHREADS
        buffer[0] = 0;
#endif

    }

    // ------------------------------------------------------------------------
    // Stack traces

#if LOGURU_STACKTRACES
    Text demangle(const char* name)
    {
        int status = -1;
        char* demangled = abi::__cxa_demangle(name, 0, 0, &amp;status);
        Text result{status == 0 ? demangled : STRDUP(name)};
        return result;
    }

    #if LOGURU_RTTI
        template &lt;class T&gt;
        std::string type_name()
        {
            auto demangled = demangle(typeid(T).name());
            return demangled.c_str();
        }
    #endif // LOGURU_RTTI

    static const StringPairList REPLACE_LIST = {
        #if LOGURU_RTTI
            { type_name&lt;std::string&gt;(),    &#34;std::string&#34;    },
            { type_name&lt;std::wstring&gt;(),   &#34;std::wstring&#34;   },
            { type_name&lt;std::u16string&gt;(), &#34;std::u16string&#34; },
            { type_name&lt;std::u32string&gt;(), &#34;std::u32string&#34; },
        #endif // LOGURU_RTTI
        { &#34;std::__1::&#34;,                &#34;std::&#34;          },
        { &#34;__thiscall &#34;,               &#34;&#34;               },
        { &#34;__cdecl &#34;,                  &#34;&#34;               },
    };

    void do_replacements(const StringPairList&amp; replacements, std::string&amp; str)
    {
        for (auto&amp;&amp; p : replacements) {
            if (p.first.size() &lt;= p.second.size()) {
                // On gcc, &#34;type_name&lt;std::string&gt;()&#34; is &#34;std::string&#34;
                continue;
            }

            size_t it;
            while ((it=str.find(p.first)) != std::string::npos) {
                str.replace(it, p.first.size(), p.second);
            }
        }
    }

    std::string prettify_stacktrace(const std::string&amp; input)
    {
        std::string output = input;

        do_replacements(s_user_stack_cleanups, output);
        do_replacements(REPLACE_LIST, output);

        try {
            std::regex std_allocator_re(R&#34;(,\s*std::allocator&lt;[^&lt;&gt;]&#43;&gt;)&#34;);
            output = std::regex_replace(output, std_allocator_re, std::string(&#34;&#34;));

            std::regex template_spaces_re(R&#34;(&lt;\s*([^&lt;&gt; ]&#43;)\s*&gt;)&#34;);
            output = std::regex_replace(output, template_spaces_re, std::string(&#34;&lt;$1&gt;&#34;));
        } catch (std::regex_error&amp;) {
            // Probably old GCC.
        }

        return output;
    }

    std::string stacktrace_as_stdstring(int skip)
    {
        // From https://gist.github.com/fmela/591333
        void* callstack[128];
        const auto max_frames = sizeof(callstack) / sizeof(callstack[0]);
        int num_frames = backtrace(callstack, max_frames);
        char** symbols = backtrace_symbols(callstack, num_frames);

        std::string result;
        // Print stack traces so the most relevant ones are written last
        // Rationale: http://yellerapp.com/posts/2015-01-22-upside-down-stacktraces.html
        for (int i = num_frames - 1; i &gt;= skip; --i) {
            char buf[1024];
            Dl_info info;
            if (dladdr(callstack[i], &amp;info) &amp;&amp; info.dli_sname) {
                char* demangled = NULL;
                int status = -1;
                if (info.dli_sname[0] == &#39;_&#39;) {
                    demangled = abi::__cxa_demangle(info.dli_sname, 0, 0, &amp;status);
                }
                snprintf(buf, sizeof(buf), &#34;%-3d %*p %s &#43; %zd\n&#34;,
                         i - skip, int(2 &#43; sizeof(void*) * 2), callstack[i],
                         status == 0 ? demangled :
                         info.dli_sname == 0 ? symbols[i] : info.dli_sname,
                         static_cast&lt;char*&gt;(callstack[i]) - static_cast&lt;char*&gt;(info.dli_saddr));
                free(demangled);
            } else {
                snprintf(buf, sizeof(buf), &#34;%-3d %*p %s\n&#34;,
                         i - skip, int(2 &#43; sizeof(void*) * 2), callstack[i], symbols[i]);
            }
            result &#43;= buf;
        }
        free(symbols);

        if (num_frames == max_frames) {
            result = &#34;[truncated]\n&#34; &#43; result;
        }

        if (!result.empty() &amp;&amp; result[result.size() - 1] == &#39;\n&#39;) {
            result.resize(result.size() - 1);
        }

        return prettify_stacktrace(result);
    }

#else // LOGURU_STACKTRACES
    Text demangle(const char* name)
    {
        return Text(STRDUP(name));
    }

    std::string stacktrace_as_stdstring(int)
    {
        // No stacktraces available on this platform&#34;
        return &#34;&#34;;
    }

#endif // LOGURU_STACKTRACES

    Text stacktrace(int skip)
    {
        auto str = stacktrace_as_stdstring(skip &#43; 1);
        return Text(STRDUP(str.c_str()));
    }

    // ------------------------------------------------------------------------

    static void print_preamble_header(char* out_buff, size_t out_buff_size)
    {
        if (out_buff_size == 0) { return; }
        out_buff[0] = &#39;\0&#39;;
        long pos = 0;
        if (g_preamble_date &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;date       &#34;);
        }
        if (g_preamble_time &amp;&amp; pos &lt; out_buff_size) {
            // pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;time         &#34;);
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;time            &#34;);
        }
        if (g_preamble_uptime &amp;&amp; pos &lt; out_buff_size) {
            // pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;( uptime  ) &#34;);
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;(  uptime  ) &#34;);
        }
        if (g_preamble_thread &amp;&amp; pos &lt; out_buff_size) {
            //pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;[%-*s]&#34;, LOGURU_THREADNAME_WIDTH, &#34; thread name/id&#34;);
			pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;[%-*s]&#34;, LOGURU_THREADNAME_WIDTH, &#34; thread id &#34;);
        }
        if (g_preamble_file &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%*s:line  &#34;, LOGURU_FILENAME_WIDTH, &#34;file&#34;);
        }
        if (g_preamble_verbose &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;   v&#34;);
        }
        if (g_preamble_pipe &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;| &#34;);
        }
    }

    static void print_preamble(char* out_buff, size_t out_buff_size, Verbosity verbosity, const char* file, unsigned line)
    {
        if (out_buff_size == 0) { return; }
        out_buff[0] = &#39;\0&#39;;
        if (!g_preamble) { return; }
        long long ms_since_epoch = duration_cast&lt;microseconds&gt;(system_clock::now().time_since_epoch()).count();
        time_t sec_since_epoch = time_t(ms_since_epoch / 1000000);
        tm time_info;
        localtime_r(&amp;sec_since_epoch, &amp;time_info);

        auto uptime_ms = duration_cast&lt;milliseconds&gt;(steady_clock::now() - s_start_time).count();
        auto uptime_sec = uptime_ms / 1000.0;

        char thread_name[LOGURU_THREADNAME_WIDTH &#43; 1] = {0};
        get_thread_name(thread_name, LOGURU_THREADNAME_WIDTH &#43; 1, true);

        if (s_strip_file_path) {
            file = filename(file);
        }

        char level_buff[6];
        const char* custom_level_name = get_verbosity_name(verbosity);
        if (custom_level_name) {
            snprintf(level_buff, sizeof(level_buff) - 1, &#34;%s&#34;, custom_level_name);
        } else {
            snprintf(level_buff, sizeof(level_buff) - 1, &#34;% 4d&#34;, verbosity);
        }

        long pos = 0;

        if (g_preamble_date &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%04d-%02d-%02d &#34;,
                             1900 &#43; time_info.tm_year, 1 &#43; time_info.tm_mon, time_info.tm_mday);
        }
        if (g_preamble_time &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%02d:%02d:%02d.%06lld &#34;,
                           time_info.tm_hour, time_info.tm_min, time_info.tm_sec, ms_since_epoch % 1000000);
        }
        if (g_preamble_uptime &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;(%9.3fs) &#34;,
                           uptime_sec);
        }
        if (g_preamble_thread &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;[%-*s]&#34;,
                           LOGURU_THREADNAME_WIDTH, thread_name);
        }
        if (g_preamble_file &amp;&amp; pos &lt; out_buff_size) {
            char shortened_filename[LOGURU_FILENAME_WIDTH &#43; 1];
            snprintf(shortened_filename, LOGURU_FILENAME_WIDTH &#43; 1, &#34;%s&#34;, file);
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%*s:%-5u &#34;,
                           LOGURU_FILENAME_WIDTH, shortened_filename, line);
        }
        if (g_preamble_verbose &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;%4s&#34;,
                           level_buff);
        }
        if (g_preamble_pipe &amp;&amp; pos &lt; out_buff_size) {
            pos &#43;= snprintf(out_buff &#43; pos, out_buff_size - pos, &#34;| &#34;);
        }
    }

    // stack_trace_skip is just if verbosity == FATAL.
    static void log_message(int stack_trace_skip, Message&amp; message, bool with_indentation, bool abort_if_fatal)
    {
        const auto verbosity = message.verbosity;
        std::lock_guard&lt;std::recursive_mutex&gt; lock(s_mutex);

        if (message.verbosity == Verbosity_FATAL) {
            auto st = loguru::stacktrace(stack_trace_skip &#43; 2);
            if (!st.empty()) {
                RAW_LOG_F(ERROR, &#34;Stack trace:\n&#34; LOGURU_FMT(s) &#34;&#34;, st.c_str());
            }

            auto ec = loguru::get_error_context();
            if (!ec.empty()) {
                RAW_LOG_F(ERROR, &#34;&#34; LOGURU_FMT(s) &#34;&#34;, ec.c_str());
            }
        }

        if (with_indentation) {
            message.indentation = indentation(s_stderr_indentation);
        }

        if (verbosity &lt;= g_stderr_verbosity) {
            if (g_colorlogtostderr &amp;&amp; s_terminal_has_color) {
                if (verbosity &gt; Verbosity_WARNING) {
                    fprintf(stderr, &#34;%s%s%s%s%s%s%s%s\n&#34;,
                        terminal_reset(),
                        terminal_dim(),
                        message.preamble,
                        message.indentation,
                        verbosity == Verbosity_INFO ? terminal_reset() : &#34;&#34;, // un-dim for info
                        message.prefix,
                        message.message,
                        terminal_reset());
                } else {
                    fprintf(stderr, &#34;%s%s%s%s%s%s%s\n&#34;,
                        terminal_reset(),
                        verbosity == Verbosity_WARNING ? terminal_yellow() : terminal_red(),
                        message.preamble,
                        message.indentation,
                        message.prefix,
                        message.message,
                        terminal_reset());
                }
            } else {
                fprintf(stderr, &#34;%s%s%s%s\n&#34;,
                    message.preamble, message.indentation, message.prefix, message.message);
            }

            if (g_flush_interval_ms == 0) {
                fflush(stderr);
            } else {
                s_needs_flushing = true;
            }
        }

        for (auto&amp; p : s_callbacks) {
            if (verbosity &lt;= p.verbosity) {
                if (with_indentation) {
                    message.indentation = indentation(p.indentation);
                }
                p.callback(p.user_data, message);
                if (g_flush_interval_ms == 0) {
                    if (p.flush) { p.flush(p.user_data); }
                } else {
                    s_needs_flushing = true;
                }
            }
        }

        if (g_flush_interval_ms &gt; 0 &amp;&amp; !s_flush_thread) {
            s_flush_thread = new std::thread([](){
                for (;;) {
                    if (s_needs_flushing) {
                        flush();
                    }
                    std::this_thread::sleep_for(std::chrono::milliseconds(g_flush_interval_ms));
                }
            });
        }

        if (message.verbosity == Verbosity_FATAL) {
            flush();

            if (s_fatal_handler) {
                s_fatal_handler(message);
                flush();
            }

            if (abort_if_fatal) {
#if LOGURU_CATCH_SIGABRT &amp;&amp; !defined(_WIN32)
                // Make sure we don&#39;t catch our own abort:
                signal(SIGABRT, SIG_DFL);
#endif
                abort();
            }
        }
    }

    // stack_trace_skip is just if verbosity == FATAL.
    void log_to_everywhere(int stack_trace_skip, Verbosity verbosity,
                           const char* file, unsigned line,
                           const char* prefix, const char* buff)
    {
        char preamble_buff[LOGURU_PREAMBLE_WIDTH];
        print_preamble(preamble_buff, sizeof(preamble_buff), verbosity, file, line);
        auto message = Message{verbosity, file, line, preamble_buff, &#34;&#34;, prefix, buff};
        log_message(stack_trace_skip &#43; 1, message, true, true);
    }

#if LOGURU_USE_FMTLIB
    void vlog(Verbosity verbosity, const char* file, unsigned line, const char* format, fmt::format_args args)
    {
        auto formatted = fmt::vformat(format, args);
        log_to_everywhere(1, verbosity, file, line, &#34;&#34;, formatted.c_str());
    }

    void raw_vlog(Verbosity verbosity, const char* file, unsigned line, const char* format, fmt::format_args args)
    {
        auto formatted = fmt::vformat(format, args);
        auto message = Message{verbosity, file, line, &#34;&#34;, &#34;&#34;, &#34;&#34;, formatted.c_str()};
        log_message(1, message, false, true);
    }
#else
    void log(Verbosity verbosity, const char* file, unsigned line, const char* format, ...)
    {
        va_list vlist;
        va_start(vlist, format);
        auto buff = vtextprintf(format, vlist);
        log_to_everywhere(1, verbosity, file, line, &#34;&#34;, buff.c_str());
        va_end(vlist);
    }

    void raw_log(Verbosity verbosity, const char* file, unsigned line, const char* format, ...)
    {
        va_list vlist;
        va_start(vlist, format);
        auto buff = vtextprintf(format, vlist);
        auto message = Message{verbosity, file, line, &#34;&#34;, &#34;&#34;, &#34;&#34;, buff.c_str()};
        log_message(1, message, false, true);
        va_end(vlist);
    }
#endif

    void flush()
    {
        std::lock_guard&lt;std::recursive_mutex&gt; lock(s_mutex);
        fflush(stderr);
        for (const auto&amp; callback : s_callbacks)
        {
            if (callback.flush) {
                callback.flush(callback.user_data);
            }
        }
        s_needs_flushing = false;
    }

    LogScopeRAII::LogScopeRAII(Verbosity verbosity, const char* file, unsigned line, const char* format, ...)
        : _verbosity(verbosity), _file(file), _line(line)
    {
        if (verbosity &lt;= current_verbosity_cutoff()) {
            std::lock_guard&lt;std::recursive_mutex&gt; lock(s_mutex);
            _indent_stderr = (verbosity &lt;= g_stderr_verbosity);
            _start_time_ns = now_ns();
            va_list vlist;
            va_start(vlist, format);
            vsnprintf(_name, sizeof(_name), format, vlist);
            log_to_everywhere(1, _verbosity, file, line, &#34;{ &#34;, _name);
            va_end(vlist);

            if (_indent_stderr) {
                &#43;&#43;s_stderr_indentation;
            }

            for (auto&amp; p : s_callbacks) {
                if (verbosity &lt;= p.verbosity) {
                    &#43;&#43;p.indentation;
                }
            }
        } else {
            _file = nullptr;
        }
    }

    LogScopeRAII::~LogScopeRAII()
    {
        if (_file) {
            std::lock_guard&lt;std::recursive_mutex&gt; lock(s_mutex);
            if (_indent_stderr &amp;&amp; s_stderr_indentation &gt; 0) {
                --s_stderr_indentation;
            }
            for (auto&amp; p : s_callbacks) {
                // Note: Callback indentation cannot change!
                if (_verbosity &lt;= p.verbosity) {
                    // in unlikely case this callback is new
                    if (p.indentation &gt; 0) {
                        --p.indentation;
                    }
                }
            }
#if LOGURU_VERBOSE_SCOPE_ENDINGS
            auto duration_sec = (now_ns() - _start_time_ns) / 1e9;
#if LOGURU_USE_FMTLIB
            auto buff = textprintf(&#34;[{:.{}f} s]: {:s}&#34;, duration_sec, LOGURU_SCOPE_TIME_PRECISION, _name);
#else
            auto buff = textprintf(&#34;[%.*f s]: %s&#34;, LOGURU_SCOPE_TIME_PRECISION, duration_sec, _name);
#endif
            log_to_everywhere(1, _verbosity, _file, _line, &#34;} &#34;, buff.c_str());
#else
            log_to_everywhere(1, _verbosity, _file, _line, &#34;}&#34;, &#34;&#34;);
#endif
        }
    }

#if LOGURU_USE_FMTLIB
    void vlog_and_abort(int stack_trace_skip, const char* expr, const char* file, unsigned line, const char* format, fmt::format_args args)
    {
        auto formatted = fmt::vformat(format, args);
        log_to_everywhere(stack_trace_skip &#43; 1, Verbosity_FATAL, file, line, expr, formatted.c_str());
        abort(); // log_to_everywhere already does this, but this makes the analyzer happy.
    }
#else
    void log_and_abort(int stack_trace_skip, const char* expr, const char* file, unsigned line, const char* format, ...)
    {
        va_list vlist;
        va_start(vlist, format);
        auto buff = vtextprintf(format, vlist);
        log_to_everywhere(stack_trace_skip &#43; 1, Verbosity_FATAL, file, line, expr, buff.c_str());
        va_end(vlist);
        abort(); // log_to_everywhere already does this, but this makes the analyzer happy.
    }
#endif

    void log_and_abort(int stack_trace_skip, const char* expr, const char* file, unsigned line)
    {
        log_and_abort(stack_trace_skip &#43; 1, expr, file, line, &#34; &#34;);
    }

    // ----------------------------------------------------------------------------
    // Streams:

#if LOGURU_USE_FMTLIB
    template&lt;typename... Args&gt;
    std::string vstrprintf(const char* format, const Args&amp;... args)
    {
        auto text = textprintf(format, args...);
        std::string result = text.c_str();
        return result;
    }

    template&lt;typename... Args&gt;
    std::string strprintf(const char* format, const Args&amp;... args)
    {
        return vstrprintf(format, args...);
    }
#else
    std::string vstrprintf(const char* format, va_list vlist)
    {
        auto text = vtextprintf(format, vlist);
        std::string result = text.c_str();
        return result;
    }

    std::string strprintf(const char* format, ...)
    {
        va_list vlist;
        va_start(vlist, format);
        auto result = vstrprintf(format, vlist);
        va_end(vlist);
        return result;
    }
#endif

    #if LOGURU_WITH_STREAMS

    StreamLogger::~StreamLogger() noexcept(false)
    {
        auto message = _ss.str();
        log(_verbosity, _file, _line, LOGURU_FMT(s), message.c_str());
    }

    AbortLogger::~AbortLogger() noexcept(false)
    {
        auto message = _ss.str();
        loguru::log_and_abort(1, _expr, _file, _line, LOGURU_FMT(s), message.c_str());
    }

    #endif // LOGURU_WITH_STREAMS

    // ----------------------------------------------------------------------------
    // 888888 88&#34;&#34;Yb 88&#34;&#34;Yb  dP&#34;Yb  88&#34;&#34;Yb      dP&#34;&#34;b8  dP&#34;Yb  88b 88 888888 888888 Yb  dP 888888
    // 88__   88__dP 88__dP dP   Yb 88__dP     dP   `&#34; dP   Yb 88Yb88   88   88__    YbdP    88
    // 88&#34;&#34;   88&#34;Yb  88&#34;Yb  Yb   dP 88&#34;Yb      Yb      Yb   dP 88 Y88   88   88&#34;&#34;    dPYb    88
    // 888888 88  Yb 88  Yb  YbodP  88  Yb      YboodP  YbodP  88  Y8   88   888888 dP  Yb   88
    // ----------------------------------------------------------------------------

    struct StringStream
    {
        std::string str;
    };

    // Use this in your EcPrinter implementations.
    void stream_print(StringStream&amp; out_string_stream, const char* text)
    {
        out_string_stream.str &#43;= text;
    }

    // ----------------------------------------------------------------------------

    using ECPtr = EcEntryBase*;

#if defined(_WIN32) || (defined(__APPLE__) &amp;&amp; !TARGET_OS_IPHONE)
    #ifdef __APPLE__
        #define LOGURU_THREAD_LOCAL __thread
    #else
        #define LOGURU_THREAD_LOCAL thread_local
    #endif
    static LOGURU_THREAD_LOCAL ECPtr thread_ec_ptr = nullptr;

    ECPtr&amp; get_thread_ec_head_ref()
    {
        return thread_ec_ptr;
    }
#else // !thread_local
    static pthread_once_t s_ec_pthread_once = PTHREAD_ONCE_INIT;
    static pthread_key_t  s_ec_pthread_key;

    void free_ec_head_ref(void* io_error_context)
    {
        delete reinterpret_cast&lt;ECPtr*&gt;(io_error_context);
    }

    void ec_make_pthread_key()
    {
        (void)pthread_key_create(&amp;s_ec_pthread_key, free_ec_head_ref);
    }

    ECPtr&amp; get_thread_ec_head_ref()
    {
        (void)pthread_once(&amp;s_ec_pthread_once, ec_make_pthread_key);
        auto ec = reinterpret_cast&lt;ECPtr*&gt;(pthread_getspecific(s_ec_pthread_key));
        if (ec == nullptr) {
            ec = new ECPtr(nullptr);
            (void)pthread_setspecific(s_ec_pthread_key, ec);
        }
        return *ec;
    }
#endif // !thread_local

    // ----------------------------------------------------------------------------

    EcHandle get_thread_ec_handle()
    {
        return get_thread_ec_head_ref();
    }

    Text get_error_context()
    {
        return get_error_context_for(get_thread_ec_head_ref());
    }

    Text get_error_context_for(const EcEntryBase* ec_head)
    {
        std::vector&lt;const EcEntryBase*&gt; stack;
        while (ec_head) {
            stack.push_back(ec_head);
            ec_head = ec_head-&gt;_previous;
        }
        std::reverse(stack.begin(), stack.end());

        StringStream result;
        if (!stack.empty()) {
            result.str &#43;= &#34;------------------------------------------------\n&#34;;
            for (auto entry : stack) {
                const auto description = std::string(entry-&gt;_descr) &#43; &#34;:&#34;;
#if LOGURU_USE_FMTLIB
                auto prefix = textprintf(&#34;[ErrorContext] {.{}s}:{:-5u} {:-20s} &#34;,
                    filename(entry-&gt;_file), LOGURU_FILENAME_WIDTH, entry-&gt;_line, description.c_str());
#else
                auto prefix = textprintf(&#34;[ErrorContext] %*s:%-5u %-20s &#34;,
                    LOGURU_FILENAME_WIDTH, filename(entry-&gt;_file), entry-&gt;_line, description.c_str());
#endif
                result.str &#43;= prefix.c_str();
                entry-&gt;print_value(result);
                result.str &#43;= &#34;\n&#34;;
            }
            result.str &#43;= &#34;------------------------------------------------&#34;;
        }
        return Text(STRDUP(result.str.c_str()));
    }

    EcEntryBase::EcEntryBase(const char* file, unsigned line, const char* descr)
        : _file(file), _line(line), _descr(descr)
    {
        EcEntryBase*&amp; ec_head = get_thread_ec_head_ref();
        _previous = ec_head;
        ec_head = this;
    }

    EcEntryBase::~EcEntryBase()
    {
        get_thread_ec_head_ref() = _previous;
    }

    // ------------------------------------------------------------------------

    Text ec_to_text(const char* value)
    {
        // Add quotes around the string to make it obvious where it begin and ends.
        // This is great for detecting erroneous leading or trailing spaces in e.g. an identifier.
        auto str = &#34;\&#34;&#34; &#43; std::string(value) &#43; &#34;\&#34;&#34;;
        return Text{STRDUP(str.c_str())};
    }

    Text ec_to_text(char c)
    {
        // Add quotes around the character to make it obvious where it begin and ends.
        std::string str = &#34;&#39;&#34;;

        auto write_hex_digit = [&amp;](unsigned num)
        {
            if (num &lt; 10u) { str &#43;= char(&#39;0&#39; &#43; num); }
            else           { str &#43;= char(&#39;a&#39; &#43; num - 10); }
        };

        auto write_hex_16 = [&amp;](uint16_t n)
        {
            write_hex_digit((n &gt;&gt; 12u) &amp; 0x0f);
            write_hex_digit((n &gt;&gt;  8u) &amp; 0x0f);
            write_hex_digit((n &gt;&gt;  4u) &amp; 0x0f);
            write_hex_digit((n &gt;&gt;  0u) &amp; 0x0f);
        };

        if      (c == &#39;\\&#39;) { str &#43;= &#34;\\\\&#34;; }
        else if (c == &#39;\&#34;&#39;) { str &#43;= &#34;\\\&#34;&#34;; }
        else if (c == &#39;\&#39;&#39;) { str &#43;= &#34;\\\&#39;&#34;; }
        else if (c == &#39;\0&#39;) { str &#43;= &#34;\\0&#34;;  }
        else if (c == &#39;\b&#39;) { str &#43;= &#34;\\b&#34;;  }
        else if (c == &#39;\f&#39;) { str &#43;= &#34;\\f&#34;;  }
        else if (c == &#39;\n&#39;) { str &#43;= &#34;\\n&#34;;  }
        else if (c == &#39;\r&#39;) { str &#43;= &#34;\\r&#34;;  }
        else if (c == &#39;\t&#39;) { str &#43;= &#34;\\t&#34;;  }
        else if (0 &lt;= c &amp;&amp; c &lt; 0x20) {
            str &#43;= &#34;\\u&#34;;
            write_hex_16(static_cast&lt;uint16_t&gt;(c));
        } else { str &#43;= c; }

        str &#43;= &#34;&#39;&#34;;

        return Text{STRDUP(str.c_str())};
    }

    #define DEFINE_EC(Type)                        \
        Text ec_to_text(Type value)                \
        {                                          \
            auto str = std::to_string(value);      \
            return Text{STRDUP(str.c_str())};      \
        }

    DEFINE_EC(int)
    DEFINE_EC(unsigned int)
    DEFINE_EC(long)
    DEFINE_EC(unsigned long)
    DEFINE_EC(long long)
    DEFINE_EC(unsigned long long)
    DEFINE_EC(float)
    DEFINE_EC(double)
    DEFINE_EC(long double)

    #undef DEFINE_EC

    Text ec_to_text(EcHandle ec_handle)
    {
        Text parent_ec = get_error_context_for(ec_handle);
        size_t buffer_size = strlen(parent_ec.c_str()) &#43; 2;
        char* with_newline = reinterpret_cast&lt;char*&gt;(malloc(buffer_size));
        with_newline[0] = &#39;\n&#39;;
    #ifdef _WIN32
        strncpy_s(with_newline &#43; 1, buffer_size, parent_ec.c_str(), buffer_size - 2);
    #else
        strcpy(with_newline &#43; 1, parent_ec.c_str());
    #endif
        return Text(with_newline);
    }

    // ----------------------------------------------------------------------------

} // namespace loguru

// ----------------------------------------------------------------------------
// .dP&#34;Y8 88  dP&#34;&#34;b8 88b 88    db    88     .dP&#34;Y8
// `Ybo.&#34; 88 dP   `&#34; 88Yb88   dPYb   88     `Ybo.&#34;
// o.`Y8b 88 Yb  &#34;88 88 Y88  dP__Yb  88  .o o.`Y8b
// 8bodP&#39; 88  YboodP 88  Y8 dP&#34;&#34;&#34;&#34;Yb 88ood8 8bodP&#39;
// ----------------------------------------------------------------------------

#ifdef _WIN32
namespace loguru {
    void install_signal_handlers(bool unsafe_signal_handler)
    {
        (void)unsafe_signal_handler;
        // TODO: implement signal handlers on windows
    }
} // namespace loguru

#else // _WIN32

namespace loguru
{
    struct Signal
    {
        int         number;
        const char* name;
    };
    const Signal ALL_SIGNALS[] = {
#if LOGURU_CATCH_SIGABRT
        { SIGABRT, &#34;SIGABRT&#34; },
#endif
        { SIGBUS,  &#34;SIGBUS&#34;  },
        { SIGFPE,  &#34;SIGFPE&#34;  },
        { SIGILL,  &#34;SIGILL&#34;  },
        { SIGINT,  &#34;SIGINT&#34;  },
        { SIGSEGV, &#34;SIGSEGV&#34; },
        { SIGTERM, &#34;SIGTERM&#34; },
    };

    void write_to_stderr(const char* data, size_t size)
    {
        auto result = write(STDERR_FILENO, data, size);
        (void)result; // Ignore errors.
    }

    void write_to_stderr(const char* data)
    {
        write_to_stderr(data, strlen(data));
    }

    void call_default_signal_handler(int signal_number)
    {
        struct sigaction sig_action;
        memset(&amp;sig_action, 0, sizeof(sig_action));
        sigemptyset(&amp;sig_action.sa_mask);
        sig_action.sa_handler = SIG_DFL;
        sigaction(signal_number, &amp;sig_action, NULL);
        kill(getpid(), signal_number);
    }

    static bool s_unsafe_signal_handler = false;

    void signal_handler(int signal_number, siginfo_t*, void*)
    {
        const char* signal_name = &#34;UNKNOWN SIGNAL&#34;;

        for (const auto&amp; s : ALL_SIGNALS) {
            if (s.number == signal_number) {
                signal_name = s.name;
                break;
            }
        }

        // --------------------------------------------------------------------
        /* There are few things that are safe to do in a signal handler,
           but writing to stderr is one of them.
           So we first print out what happened to stderr so we&#39;re sure that gets out,
           then we do the unsafe things, like logging the stack trace.
        */

        if (g_colorlogtostderr &amp;&amp; s_terminal_has_color) {
            write_to_stderr(terminal_reset());
            write_to_stderr(terminal_bold());
            write_to_stderr(terminal_light_red());
        }
        write_to_stderr(&#34;\n&#34;);
        write_to_stderr(&#34;Loguru caught a signal: &#34;);
        write_to_stderr(signal_name);
        write_to_stderr(&#34;\n&#34;);
        if (g_colorlogtostderr &amp;&amp; s_terminal_has_color) {
            write_to_stderr(terminal_reset());
        }

        // --------------------------------------------------------------------

        if (s_unsafe_signal_handler) {
            // --------------------------------------------------------------------
            /* Now we do unsafe things. This can for example lead to deadlocks if
               the signal was triggered from the system&#39;s memory management functions
               and the code below tries to do allocations.
            */

            flush();
            char preamble_buff[LOGURU_PREAMBLE_WIDTH];
            print_preamble(preamble_buff, sizeof(preamble_buff), Verbosity_FATAL, &#34;&#34;, 0);
            auto message = Message{Verbosity_FATAL, &#34;&#34;, 0, preamble_buff, &#34;&#34;, &#34;Signal: &#34;, signal_name};
            try {
                log_message(1, message, false, false);
            } catch (...) {
                // This can happed due to s_fatal_handler.
                write_to_stderr(&#34;Exception caught and ignored by Loguru signal handler.\n&#34;);
            }
            flush();

            // --------------------------------------------------------------------
        }

        call_default_signal_handler(signal_number);
    }

    void install_signal_handlers(bool unsafe_signal_handler)
    {
        s_unsafe_signal_handler = unsafe_signal_handler;

        struct sigaction sig_action;
        memset(&amp;sig_action, 0, sizeof(sig_action));
        sigemptyset(&amp;sig_action.sa_mask);
        sig_action.sa_flags |= SA_SIGINFO;
        sig_action.sa_sigaction = &amp;signal_handler;
        for (const auto&amp; s : ALL_SIGNALS) {
            CHECK_F(sigaction(s.number, &amp;sig_action, NULL) != -1,
                &#34;Failed to install handler for &#34; LOGURU_FMT(s) &#34;&#34;, s.name);
        }
    }
} // namespace loguru

#endif // _WIN32

#ifdef _WIN32
#ifdef _MSC_VER
#pragma warning(pop)
#endif // _MSC_VER
#endif // _WIN32

#endif // LOGURU_IMPLEMENTATION
```

## `CMakeLists.txt`

```cmake
project(loguru)
cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_FLAGS &#34;${CMAKE_CXX_FLAGS} -o3&#34;)

set(LIBRARY_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/)
add_library(loguru STATIC loguru.cpp)
target_link_libraries(loguru fmt)

```

## demo

```bash
.
├── build
├── CMakeLists.txt
└── main.cpp

1 directory, 2 files

```

### `main.cpp`

```c&#43;&#43;
#include &lt;chrono&gt;
#include &lt;thread&gt;
#define LOGURU_USE_FMTLIB 1
#include &#34;loguru.hpp&#34;

void sleep_ms(int ms)
{
	VLOG_F(2, &#34;Sleeping for %d ms&#34;, ms);
	std::this_thread::sleep_for(std::chrono::milliseconds(ms));
}

void foo()
{
	LOG_SCOPE_F(INFO, &#34;foo&#34;);
for (int i = 0; i &lt; 10; &#43;&#43;i)
{
	LOG_F(INFO, &#34;%d&#34;,  i);
	LOG_F(INFO, &#34;foo for loop&#34;);
}
}
void complex_calculation()
{
	LOG_SCOPE_F(INFO, &#34;complex_calculation&#34;);
	LOG_F(INFO, &#34;Starting time machine...&#34;);
	sleep_ms(200);
	LOG_F(WARNING, &#34;The flux capacitor is not getting enough power!&#34;);
	sleep_ms(400);
	LOG_F(INFO, &#34;Lighting strike!&#34;);
	VLOG_F(1, &#34;Found 1.21 gigawatts...&#34;);
	sleep_ms(400);
	std::thread([](){
		loguru::set_thread_name(&#34;complex_calculation&#34;);
		LOG_F(ERROR, &#34;We ended up in 1985!&#34;);
	}).join();
}
#include &lt;iostream&gt;
int main(int argc, char* argv[])
{
    loguru::init(argc, argv);
	loguru::add_file(&#34;everything.log&#34;, loguru::Append, loguru::Verbosity_MAX);
    LOG_F(INFO, &#34;Hello from main.cpp!&#34;);
	complex_calculation();
    std::string s = &#34;hello&#34;;
    LOG_F(INFO, &#34;{}&#34;, s);
	// foo();
```

### `CMakeLists.txt`

```cmake
project(demo)
cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS &#34;${CMAKE_CXX_FLAGS} -lpthread -ldl -lrt&#34;)

include_directories(../)
link_directories(../)

add_executable(demo ./main.cpp)
target_link_libraries(demo loguru fmt)
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-03-23-c&#43;&#43;%E6%97%A5%E5%BF%97%E6%A8%A1%E5%9D%97-loguru/  

