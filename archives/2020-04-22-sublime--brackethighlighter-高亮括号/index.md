# Sublime: BracketHighlighter 高亮括号


在开发一个比较大的工程项目时，有时候我们会写一些比较长的代码块。如果没有良好的插件做辅助，单单凭借肉眼很难看清整个代码的层次关系。这时候，一款得心应手的代码块高亮工具就显得十分可贵。

![](/images/2020-04-22-Sublime--BracketHighlighter-高亮括号/md-cpp.png)

像上面这个 `c&#43;&#43;` 代码，我们可以非常清晰的看到：

- 左侧边栏的 `()` 是否补全
- 在代码内部的逻辑层次

以上的实现是通过在 Sublime 安装插件 `BracketHighlighter` 来完成的。

项目地址：[BracketHighlighter Documentation](https://facelessuser.github.io/BracketHighlighter/)



# 安装

打开 `Sublime`，使用 `Shift&#43;Ctrl&#43;P` 开始搜索软件名 `BracketHighlighter`，然后安装就可以了。

# 配置

以下是我的配置方案

```json
{
    // Debug logging
    &#34;debug_enable&#34;: false,

    // When only either the left or right bracket can be found
    // this defines if the unmatched bracket should be shown.
    &#34;show_unmatched&#34;: true,

    // Do the opposite of `show_unmatched` for the languages listed below
    &#34;show_unmatched_exceptions&#34;: [],

    // Enable high visibility by default when sublime starts up
    // If sublime is already running and this gets changed,
    // you will not see any changes (restart required to see change)
    &#34;high_visibility_enabled_by_default&#34;: false,

    // Experimental: Creates a visible bar at the beginning of all lines between
    // multiline bracket spans.
    // &#34;content_highlight_bar&#34;: false,
    &#34;content_highlight_bar&#34;: true,
    // Show hover popup
    // This will show a hover popup when mousing over
    // the visible bracket if the other
    // highlighted matching bracket is off screen.
    // It will show line text of the off screen bracket -/&#43; 128 chars
    // from the bracket start and end points.
    // A link will be available allowing the user to click and jump to
    // the other bracket.
    &#34;show_offscreen_bracket_popup&#34;: true,

    // If enabled with `show_offscreen_bracket_popup`,the popup will be shown
    // even if brackets are onscreen.
    // &#34;show_bracket_popup_always&#34;: false,
    &#34;show_bracket_popup_always&#34;: true,

    // Adjust char per line context of bracket popup.
    &#34;popup_char_context&#34;: 120,

    // Adjust number of lines of additional context
    // that are shown when brackets are vertically off screen.
    // Specified line count is split to context before and after the target line.
    // So a value of 4 would give you two lines of context before and two lines after.
    &#34;popup_line_context&#34;: 2,

    // Experimental: Use `popup_bracket_emphasis` to customize the popup&#39;s bracket emphasis color
    &#34;use_custom_popup_bracket_emphasis&#34;: false,

    // Experimental: Specify the scope (to get color) to emphasize the off screen bracket
    // in popups.  Alternatively you can use a hex value in the form `#rgb` or `#rrggbb`.
    &#34;popup_bracket_emphasis&#34;: &#34;keyword&#34;,

    // Experimental: Align the content highlight bar at the bracket indent level
    // &#34;align_content_highlight_bar&#34;: false,
    &#34;align_content_highlight_bar&#34;: true,

    // Experimental: Allow bracket highlighter to search in widgets.
    // Most widgets use Plain Text which BH should ignore,
    // But regex find views views are usually regular expression
    // Which should be the only views to trigger BH.
    &#34;search_in_widgets&#34;: false,

    // Show brackets in the minimap.
    // Depending on your highlight style, regions may not be visible in minimap.
    // &#34;underline&#34; won&#39;t show up due to it being a style consisting of
    // multiple zero width selections to create a fat underline.
    // But the following styles should show up fine as they are normal regions styles:
    //     - thin_underline
    //     - solid
    //     - outline
    //     - squiggly
    //     - stippled
    // &#34;show_in_minimap&#34;: false,
    &#34;show_in_minimap&#34;: true,

    // High visibility style and color for high visibility mode
    // (`solid`|`outline`|`underline`)
    // ST3 has additional options of (`thin_underline`|`squiggly`|`stippled`)
    &#34;high_visibility_style&#34;: &#34;outline&#34;,

    // (scope|__default__|__bracket__)
    &#34;high_visibility_color&#34;: &#34;__bracket__&#34;,

    // Match brackets only when the cursor is touching the inside of the bracket
    &#34;match_only_adjacent&#34;: false,

    // Outside adjacent bracket matching
    &#34;bracket_outside_adjacent&#34;: true,

    // Experimental: Special matching mode for block cursor.
    // Essentially, this provides a matching mode that makes a little more
    // sense to some in regards to the visual representation of block cursors.
    // This will ignore `bracket_outside_adjacent`.
    &#34;block_cursor_mode&#34;: false,

    // When `bracket_outside_adjacent` is set, and a plugin command explicitly sets
    // `no_outside_adj` to `None` instead of `true` or the default `false`,
    // this value will be used.
    &#34;ignore_outside_adjacent_in_plugin&#34;: true,

    // When `block_cursor_mode` is set, and a plugin command explicitly sets
    // &#34;no_block_mode&#34; to `None` instead of `true` or the default `false`,
    // this value will be used.
    &#34;ignore_block_mode_in_plugin&#34;: true,

    // Character threshold to search
    &#34;search_threshold&#34;: 5000,

    // Ignore threshold
    &#34;ignore_threshold&#34;: false,

    // Set mode for string escapes to ignore (`regex`|`string`)
    &#34;bracket_string_escape_mode&#34;: &#34;string&#34;,

    // Set max number of multi-select brackets that will be searched automatically
    &#34;auto_selection_threshold&#34; : 10,

    // Enable this to completely kill highlighting if &#34;auto_selection_threshold&#34;
    // is exceeded.  Default is to highlight up to the &#34;auto_selection_threshold&#34;.
    &#34;kill_highlight_on_threshold&#34;: true,

    // Disable gutter icons when doing multi-select
    &#34;no_multi_select_icons&#34;: false,

    // Rules that define the finding and matching of brackets
    // that are contained in a common scope.
    // Useful for bracket pairs that are the same but
    // share a common scope.  Brackets are found by
    // Finding the extent of the scope and using regex
    // to look at the beginning and end to identify bracket.
    // Use only if they cannot be targeted with traditional bracket
    // rules.
    &#34;scope_brackets&#34;: [
        // Quotes
        {
            &#34;name&#34;: &#34;py_single_quote&#34;,
            &#34;open&#34;: &#34;(?:u|b|f)?r?((?:&#39;&#39;)?&#39;)&#34;,
            &#34;close&#34;: &#34;((?:&#39;&#39;)?&#39;)&#34;,
            &#34;style&#34;: &#34;single_quote&#34;,
            &#34;scopes&#34;: [&#34;string&#34;, &#34;meta.string&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [
                &#34;Python&#34;,
                &#34;PythonImproved&#34;,
                &#34;MagicPython&#34;
            ],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;plugin_library&#34;: &#34;bh_modules.pyquotes&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;py_double_quote&#34;,
            &#34;open&#34;: &#34;(?:u|b|f)?r?((?:\&#34;\&#34;)?\&#34;)&#34;,
            &#34;close&#34;: &#34;((?:\&#34;\&#34;)?\&#34;)&#34;,
            &#34;style&#34;: &#34;double_quote&#34;,
            &#34;scopes&#34;: [&#34;string&#34;, &#34;meta.string&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [
                &#34;Python&#34;,
                &#34;PythonImproved&#34;,
                &#34;MagicPython&#34;
            ],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;plugin_library&#34;: &#34;bh_modules.pyquotes&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;csharp_double_quote&#34;,
            &#34;open&#34;: &#34;\\$?@?(\&#34;)&#34;,
            &#34;close&#34;: &#34;(\&#34;)&#34;,
            &#34;style&#34;: &#34;double_quote&#34;,
            &#34;scopes&#34;: [&#34;string.quoted.double&#34;, &#34;meta.string.interpolated&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;C#&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;single_quote&#34;,
            &#34;open&#34;: &#34;(&#39;)&#34;,
            &#34;close&#34;: &#34;(&#39;)&#34;,
            &#34;style&#34;: &#34;single_quote&#34;,
            &#34;scopes&#34;: [
                &#34;meta.attribute-with-value.style.html -entity.other.attribute-name.style.html -punctuation.separator.key-value.html&#34;,
                &#34;source.ruby string.quoted, source.ruby meta.interpolation&#34;,
                &#34;string&#34;,
                &#34;string.quoted&#34;
            ],
            &#34;language_filter&#34;: &#34;blacklist&#34;,
            &#34;language_list&#34;: [&#34;Plain text&#34;, &#34;Hex&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;double_quote&#34;,
            &#34;open&#34;: &#34;(\&#34;)&#34;,
            &#34;close&#34;: &#34;(\&#34;)&#34;,
            &#34;style&#34;: &#34;double_quote&#34;,
            &#34;scopes&#34;: [
                &#34;meta.attribute-with-value.style.html -entity.other.attribute-name.style.html -punctuation.separator.key-value.html&#34;,
                &#34;source.ruby string.quoted, source.ruby meta.interpolation&#34;,
                &#34;string&#34;,
                &#34;string.quoted&#34;
            ],
            &#34;language_filter&#34;: &#34;blacklist&#34;,
            &#34;language_list&#34;: [&#34;Plain text&#34;, &#34;Hex&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;backtick_quote&#34;,
            &#34;open&#34;: &#34;(`)&#34;,
            &#34;close&#34;: &#34;(`)&#34;,
            &#34;style&#34;: &#34;single_quote&#34;,
            &#34;scopes&#34;: [
                &#34;string.interpolated.ruby&#34;,
                &#34;string.interpolated.backtick.shell&#34;,
                &#34;string.template-string.js&#34;,
                &#34;string.template.js, meta.template.expression.js&#34;
            ],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Ruby&#34;, &#34;Shell-Unix-Generic&#34;, &#34;Bash&#34;, &#34;JavaScript&#34;, &#34;JavaScriptNext&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        // Regex for different Languages
        {
            &#34;name&#34;: &#34;jsregex&#34;,
            &#34;open&#34;: &#34; *(/)&#34;,
            &#34;close&#34;: &#34;(/)[igm]*&#34;,
            &#34;style&#34;: &#34;regex&#34;,
            &#34;scopes&#34;: [&#34;string&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;JavaScript&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;perlregex&#34;,
            &#34;open&#34;: &#34;(?:m|s|tr)(.|\n)&#34;,
            &#34;close&#34;: &#34;(.|\n)(?:[igmos]*)&#34;,
            &#34;style&#34;: &#34;regex&#34;,
            &#34;scopes&#34;: [&#34;string.regexp&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Perl&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;rubyregex&#34;,
            &#34;open&#34;: &#34; *(/)&#34;,
            &#34;close&#34;: &#34;(/)[imxo]*&#34;,
            &#34;style&#34;: &#34;regex&#34;,
            &#34;scopes&#34;: [&#34;string&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Ruby&#34;, &#34;RSpec&#34;, &#34;Better RSpec&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        // Markdown
        {
            &#34;name&#34;: &#34;mditalic&#34;,
            &#34;open&#34;: &#34;(\\*|_)&#34;,
            &#34;close&#34;: &#34;(\\*|_)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scopes&#34;: [&#34;markup.italic&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Markdown&#34;, &#34;Multimarkdown&#34;, &#34;GithubFlavoredMarkdown&#34;, &#34;Markdown Extended&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;mdbold&#34;,
            &#34;open&#34;: &#34;(\\*\\*|__)&#34;,
            &#34;close&#34;: &#34;(\\*\\*|__)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scopes&#34;: [&#34;markup.bold&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Markdown&#34;, &#34;Multimarkdown&#34;, &#34;GithubFlavoredMarkdown&#34;, &#34;Markdown Extended&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;mdcodeinline&#34;,
            &#34;open&#34;: &#34;(`&#43;)&#34;,
            &#34;close&#34;: &#34;(`&#43;)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scopes&#34;: [&#34;markup.raw.inline.markdown&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Markdown&#34;, &#34;Multimarkdown&#34;, &#34;GithubFlavoredMarkdown&#34;, &#34;Markdown Extended&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;plugin_library&#34;: &#34;bh_modules.mdcode&#34;,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;mdcodeblock&#34;,
            &#34;open&#34;: &#34;\\s*(`{3,}|~{3,})&#34;,
            &#34;close&#34;: &#34;(`{3,}|~{3,})\\n?&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scopes&#34;: [&#34;markup.raw.block.fenced.markdown, markup.raw.block.markdown.fenced&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Markdown&#34;, &#34;Multimarkdown&#34;, &#34;GithubFlavoredMarkdown&#34;, &#34;Markdown Extended&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.mdcode&#34;,
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        // LaTeX
        {
            &#34;name&#34;: &#34;latexmath_inline&#34;,
            &#34;open&#34;: &#34;(\\$)&#34;,
            &#34;close&#34;: &#34;(\\$)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scopes&#34;: [&#34;string.other.math.tex&#34;, &#34;meta.environment.math.inline.dollar.latex&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;LaTeX&#34;, &#34;LaTeX (TikZ)&#34;, &#34;knitr (Rnw)&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        }
    ],

    // Rule definitions for finding and matching brackets.
    // Brackets are found by using regex and can use scope
    // qualifiers exclude certain matches.
    // Once all matches are found, the closest pair surrounding
    // the cursor are selected.
    &#34;brackets&#34;: [
        // OCaml
        {
            &#34;name&#34;: &#34;ocaml_comment&#34;,
            &#34;open&#34;: &#34;(\\(\\*)&#34;,
            &#34;close&#34;: &#34;(\\*\\))&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;-comment&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;OCaml&#34;],
            &#34;sub_bracket_search&#34;: &#34;false&#34;,
            &#34;enabled&#34;: true
        },
        // Basic brackets
        {
            &#34;name&#34;: &#34;curly&#34;,
            &#34;open&#34;: &#34;(\\{)&#34;,
            &#34;close&#34;: &#34;(\\})&#34;,
            &#34;style&#34;: &#34;curly&#34;,
            &#34;scope_exclude&#34;: [
                &#34;string&#34;,
                &#34;comment&#34;,
                &#34;source.regexp constant.character.escape&#34;,
                &#34;source.yaml-tmlanguage constant.character.escape&#34;
            ],
            &#34;scope_exclude_exceptions&#34;: [&#34;text.tex string.other.math&#34;],
            &#34;language_filter&#34;: &#34;blacklist&#34;,
            &#34;language_list&#34;: [&#34;Plain text&#34;, &#34;Hex&#34;],
            &#34;find_in_sub_search&#34;: &#34;true&#34;,
            &#34;ignore_string_escape&#34;: true,
            &#34;enabled&#34;: true
        },
        {
            &#34;name&#34;: &#34;round&#34;,
            &#34;open&#34;: &#34;(\\()&#34;,
            &#34;close&#34;: &#34;(\\))&#34;,
            &#34;style&#34;: &#34;round&#34;,
            &#34;scope_exclude_exceptions&#34;: [
                &#34;text.tex string.other.math&#34;,
                &#34;punctuation.definition.string.begin.shell&#34;,
                &#34;punctuation.definition.string.end.shell&#34;
            ],
            &#34;scope_exclude&#34;: [
                &#34;string&#34;,
                &#34;comment&#34;,
                &#34;source.regexp constant.character.escape&#34;,
                &#34;keyword.control.conditional.patterns.end.shell&#34;,
                &#34;source.yaml-tmlanguage constant.character.escape&#34;
            ],
            &#34;language_filter&#34;: &#34;blacklist&#34;,
            &#34;language_list&#34;: [&#34;Plain text&#34;, &#34;Hex&#34;, &#34;RTF&#34;],
            &#34;find_in_sub_search&#34;: &#34;true&#34;,
            &#34;ignore_string_escape&#34;: true,
            &#34;enabled&#34;: true
        },
        //XML
        {
            &#34;name&#34;:&#34;xml_cdata&#34;,
            &#34;open&#34;:&#34;(&lt;!\\[CDATA\\[)&#34;,
            &#34;close&#34;:&#34;(\\]\\]&gt;)&#34;,
            &#34;style&#34;:&#34;default&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;XML&#34;],
            &#34;scope_exclude&#34;: [
                &#34;comment&#34;
            ],
            &#34;enabled&#34;:true
        },
        {
            &#34;name&#34;: &#34;square&#34;,
            &#34;open&#34;: &#34;(\\[)&#34;,
            &#34;close&#34;: &#34;(\\])&#34;,
            &#34;style&#34;: &#34;square&#34;,
            &#34;scope_exclude&#34;: [
                &#34;string&#34;,
                &#34;source.regexp constant.character.escape&#34;,
                &#34;comment&#34;
            ],
            &#34;scope_exclude_exceptions&#34;: [&#34;text.tex string.other.math&#34;, &#34;source.yaml-tmlanguage meta.value -constant.character.escape&#34;],
            &#34;language_filter&#34;: &#34;blacklist&#34;,
            &#34;language_list&#34;: [&#34;Plain text&#34;, &#34;Hex&#34;, &#34;RTF&#34;],
            &#34;find_in_sub_search&#34;: &#34;true&#34;,
            &#34;ignore_string_escape&#34;: true,
            &#34;enabled&#34;: true
        },
        // PHP Angle
        {
            &#34;name&#34;: &#34;php_angle&#34;,
            &#34;open&#34;: &#34;(&lt;\\?)(?:php)?&#34;,
            &#34;close&#34;: &#34;(\\?&gt;)&#34;,
            &#34;style&#34;: &#34;angle&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;, &#34;keyword.operator&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;HTML&#34;, &#34;HTML 5&#34;],
            &#34;enabled&#34;: true
        },
        // Angle
        {
            &#34;name&#34;: &#34;angle&#34;,
            &#34;open&#34;: &#34;(&lt;)(?=[^?%]|$)&#34;,
            &#34;close&#34;: &#34;(?:(?&lt;=[^?%])|(?&lt;=^))(&gt;)&#34;,
            &#34;style&#34;: &#34;angle&#34;,
            &#34;scope_exclude&#34;: [
                &#34;string&#34;,
                &#34;comment&#34;,
                &#34;keyword.operator&#34;,
                &#34;source.ruby.rails.embedded.html&#34;,
                &#34;source.ruby.embedded.html&#34;,
                &#34;storage.type.function.arrow.js&#34;,
                &#34;punctuation.accessor.php&#34;,
                &#34;punctuation.accessor.arrow.php&#34;,
                &#34;source.php meta.embedded.html punctuation.section.embedded.begin.php&#34;,
                &#34;source.php meta.embedded.js punctuation.section.embedded.begin.php&#34;,
                &#34;source.php meta.embedded.css punctuation.section.embedded.begin.php&#34;
            ],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [
                &#34;HTML&#34;,
                &#34;HTML 5&#34;,
                &#34;XML&#34;,
                &#34;PHP&#34;,
                &#34;HTML (Rails)&#34;,
                &#34;HTML (Jinja Templates)&#34;,
                &#34;HTML (Jinja2)&#34;,
                &#34;HTML (Twig)&#34;,
                &#34;HTML (Django)&#34;,
                &#34;HTML&#43;CFML&#34;,
                &#34;ColdFusion&#34;,
                &#34;ColdFusionCFC&#34;,
                &#34;laravel-blade&#34;,
                &#34;blade&#34;,
                &#34;Handlebars&#34;,
                &#34;AngularJS&#34;,
                &#34;Java Server Pages (JSP)&#34;
            ],
            &#34;plugin_library&#34;: &#34;bh_modules.tags&#34;,
            &#34;enabled&#34;: true
        },
        // CSSedit groups
        {
            &#34;name&#34;: &#34;cssedit_groups&#34;,
            &#34;open&#34;: &#34;(/\\* *@group .*\\*/)&#34;,
            &#34;close&#34;: &#34;(/\\* *@end *\\*/)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;CSS&#34;],
            &#34;enabled&#34;: true
        },
        // Ruby embedded HTML
        // !!! May conflict with `php_keywords` if enabled in same file !!!
        {
            &#34;name&#34;: &#34;ruby_embedded_html&#34;,
            &#34;open&#34;: &#34;((?:(?&lt;=&lt;%)|(?&lt;=^)|(?&lt;==)|(?&lt;=&lt;&lt;))\\s*\\b(?:if|begin|case)\\b(?!:)|(?:(?&lt;=&lt;%)|(?&lt;=^))\\s*(?:(?:private|public|protected)\\s*)?def\\b[\\p{Ll}\\p{Lu}]*\\b(?!:)|(?:(?&lt;=&lt;%)|(?&lt;=^))\\s*\\b(?:for|until|unless|while|class|module)\\b(?!:)|(?&lt;!:)\\bdo\\b(?!:)|(?&lt;=return)\\s*\\b(?:begin|case|for|until|while|class|module)\\b(?!:))&#34;,
            &#34;close&#34;: &#34;(?&lt;=[\\s;])(end)\\b(?!:)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;text.html&#34;, &#34;source&#34;, &#34;comment&#34;, &#34;string&#34;],
            &#34;scope_exclude_exceptions&#34;: [
                &#34;source.ruby.rails.embedded.html -comment -string&#34;,
                &#34;source.ruby.embedded.html -comment -string&#34;
            ],
            &#34;plugin_library&#34;: &#34;bh_modules.rubykeywords&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;HTML&#34;, &#34;HTML 5&#34;, &#34;HTML (Rails)&#34;],
            &#34;enabled&#34;: true
        },
        // Ruby conditional statements
        {
            &#34;name&#34;: &#34;ruby&#34;,
            &#34;open&#34;: &#34;((?:(?&lt;=^)|(?&lt;==)|(?&lt;=&lt;&lt;))\\s*\\b(?:if|begin|case)\\b(?!:)|^\\s*(?:(?:private|public|protected)\\s*)?def\\b[\\p{Ll}\\p{Lu}]*\\b(?!:)|^\\s*\\b(?:for|until|unless|while|class|module)\\b(?!:)|(?&lt;!:)\\bdo\\b(?!:)|(?&lt;=return)\\s*\\b(?:begin|case|for|until|while|class|module)\\b(?!:))&#34;,
            &#34;close&#34;: &#34;(?&lt;=[\\s;])(end)\\b(?!:)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.rubykeywords&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Ruby&#34;, &#34;RSpec&#34;, &#34;Better RSpec&#34;, &#34;Ruby on Rails&#34;],
            &#34;enabled&#34;: true
        },
        // C/C&#43;&#43; compile switches
        {
            &#34;name&#34;: &#34;c_compile_switch&#34;,
            &#34;open&#34;: &#34;\\#[ \\t]*(if|ifdef|ifndef)\\b&#34;,
            &#34;close&#34;: &#34;\\#[ \\t]*(endif)\\b&#34;,
            &#34;style&#34;: &#34;c_define&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;C&#43;&#43;&#34;, &#34;C&#34;, &#34;Objective-C&#43;&#43;&#34;, &#34;Objective-C&#34;, &#34;CCpp&#34;, &#34;C Improved&#34;],
            &#34;enabled&#34;: true
        },
        // PHP conditional keywords
        // !!! May conflict with `ruby_embedded_html` if enabled in same file !!!
        {
            &#34;name&#34;: &#34;php_keywords&#34;,
            &#34;open&#34;: &#34;(?:(?&lt;=^)|(?&lt;=&lt;\\?php)|(?&lt;=&lt;\\?))\\s*(if|foreach|for|while|switch)\\b(?=.*?\\)\\s*:\\s*(?://.*?|/\\*.*?\\*/\\s*?)?(?:\\?&gt;|$))&#34;,
            &#34;close&#34;: &#34;(?:(?&lt;=^)|(?&lt;=&lt;\\?php)|(?&lt;=&lt;\\?))\\s*(endif|endfor|endforeach|endwhile|endswitch)\\b(?=\\s*(?:;|;?\\?&gt;))&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;, &#34;text.html&#34;],
            &#34;scope_exclude_exceptions&#34;: [
                &#34;source.php -comment -string&#34;
            ],
            &#34;plugin_library&#34;: &#34;bh_modules.phpkeywords&#34;,
            &#34;language_list&#34;: [
                &#34;HTML&#34;,
                &#34;HTML 5&#34;,
                &#34;PHP&#34;,
                &#34;HTML&#43;CFML&#34;,
                &#34;ColdFusion&#34;,
                &#34;ColdFusionCFC&#34;
            ],
            &#34;enabled&#34;: true
        },
        // Erlang conditional statements
        {
            &#34;name&#34;: &#34;erlang&#34;,
            &#34;open&#34;: &#34;\\s*(\\b(?:if|case|begin|try|fun(?=\\s*\\()|receive)\\b)&#34;,
            &#34;close&#34;: &#34;\\b(end)\\b&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;plugin_library&#34;: &#34;bh_modules.lowercase&#34;,
            &#34;language_list&#34;: [&#34;Erlang&#34;, &#34;HTML (Erlang)&#34;],
            &#34;enabled&#34;: true
        },
        //Bash
        {
            &#34;name&#34;: &#34;bash&#34;,
            &#34;open&#34;: &#34;(?:(?&lt;!\\\\\\n)(?:;|^|&amp;|\\|)\\s*)\\b(if|case|while|select|until|for)\\s&#34;,
            &#34;close&#34;: &#34;(?:(?&lt;!\\\\\\n)(?:;|^)\\s*)\\b(fi|esac|done)(?=;|\\s|$)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.bashsupport&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Shell-Unix-Generic&#34;, &#34;Bash&#34;],
            &#34;enabled&#34;: true
        },
        //Fish shell
        {
            &#34;name&#34;: &#34;fish&#34;,
            &#34;open&#34;: &#34;(?:(?&lt;!\\\\\\n)(?:;|^|&amp;|\\||and|or|not)\\s*)\\b(begin|if|while|for|switch|function)(?:;|\\s)&#34;,
            &#34;close&#34;: &#34;(?:(?&lt;!\\\\\\n)(?:;|^)\\s*)\\b(end)(?=;|\\s|$)&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;fish&#34;],
            &#34;enabled&#34;: true
        },
        // Lua
        {
            &#34;name&#34;: &#34;lua&#34;,
            &#34;open&#34;: &#34;(?:(?&lt;=[\\s;])|(?&lt;=^))(if|function|do|repeat)\\b&#34;,
            &#34;close&#34;: &#34;(?:(?&lt;=[\\s;])|(?&lt;=^))(end|until)\\b&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.luakeywords&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Lua&#34;],
            &#34;enabled&#34;: true
        },
        // LaTeX
        {
            &#34;name&#34;: &#34;latexenv&#34;,
            &#34;open&#34;: &#34;(\\\\begin{[^}]*})&#34;,
            &#34;close&#34;: &#34;(\\\\end{[^}]*})&#34;,
            &#34;style&#34;: &#34;tag&#34;,
            &#34;scope_exclude&#34;: [&#34;comment&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.latexenvironments&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;LaTeX&#34;, &#34;LaTeX (TikZ)&#34;, &#34;knitr (Rnw)&#34;],
            &#34;sub_bracket_search&#34;: &#34;true&#34;,
            &#34;enabled&#34;: true
        },
        // Pascal
        {
            &#34;name&#34;: &#34;pascal&#34;,
            &#34;open&#34;: &#34;(?:(?&lt;=^)|(?&lt;=[\\s;]))(try|(?&lt;=\\=\\s)(?:class|record|interface)|begin|repeat)\\b&#34;,
            &#34;close&#34;: &#34;(?&lt;=[\\s;])(end(?=[;\\s])|until(?=\\s))&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.pascalkeywords&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Pascal&#34;],
            &#34;enabled&#34;: true
        },
        // Elixir
        {
            &#34;name&#34;: &#34;elixir&#34;,
            &#34;open&#34;: &#34;\\b(do$|fn)\\b&#34;,
            &#34;close&#34;: &#34;\\b(end)\\b&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;Elixir&#34;],
            &#34;enabled&#34;: true
        },
        // CMake
        {
            &#34;name&#34;: &#34;cmake&#34;,
            &#34;open&#34;: &#34;\\b(foreach|function|if|macro|while)\\b&#34;,
            &#34;close&#34;: &#34;\\b(end(?:foreach|function|if|macro|while))\\b&#34;,
            &#34;style&#34;: &#34;default&#34;,
            &#34;scope_exclude&#34;: [&#34;-keyword.cmake&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.cmakekeywords&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;CMake&#34;],
            &#34;enabled&#34;: true
        },
        // `SINUMERIK 840D SL G-Code`
        {
            &#34;name&#34;: &#34;s840d_gcode&#34;,
            &#34;open&#34;: &#34;\\b(IF(?!.*GOTO)|FOR|WHILE|REPEAT(?!.*GOTO))\\b&#34;,
            &#34;close&#34;: &#34;\\b(END(?:IF|FOR|WHILE)|UNTIL)\\b&#34;,
            &#34;style&#34;: &#34;tag&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.s840d_gcode&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;s840d_gcode&#34;],
            &#34;enabled&#34;: true
        },
        // `SINUMERIK 840D SL RunMyHmi`
        {
            &#34;name&#34;: &#34;s840d_hmi&#34;,
            &#34;open&#34;: &#34;^\\s*(//[ABGMS]|ACTIVATE|CHANGE|FOCUS|IF|LOAD|UNLOAD|OUTPUT|PRESS|SUB)\\b&#34;,
            &#34;close&#34;: &#34;^\\s*(//END|END_(?:ACTIVATE|CHANGE|FOCUS|IF|LOAD|UNLOAD|OUTPUT|PRESS|SUB))\\b&#34;,
            &#34;style&#34;: &#34;tag&#34;,
            &#34;scope_exclude&#34;: [&#34;string&#34;, &#34;comment&#34;],
            &#34;plugin_library&#34;: &#34;bh_modules.s840d_hmi&#34;,
            &#34;language_filter&#34;: &#34;whitelist&#34;,
            &#34;language_list&#34;: [&#34;s840d_hmi&#34;],
            &#34;enabled&#34;: true
        }
    ],

    // `user_scope_brackets` and `user_brackets` will be appended
    // to the tail of scope_brackets and brackets respectively
    // If you have custom rules that you don&#39;t want to commit to
    // the official list, and do not need to be inserted before
    // one of the official definitions, this is a good place to
    // put yours rules and keep in sync with the defaults.
    // If you want to disable all gutter icons, please set icon
    // to none for all region with user_bracket_styles
    &#34;user_scope_brackets&#34;: [],
    &#34;user_brackets&#34;: [],
    &#34;user_bracket_styles&#34;: {},

    // Define region highlight styles
    &#34;bracket_styles&#34;: {
        // `default` and `unmatched` styles are special
        // styles. If they are not defined here,
        // they will be generated internally with
        // internal defaults.

        // `default` style defines attributes that
        // will be used for any style that does not
        // explicitly define that attribute.  So if
        // a style does not define a color, it will
        // use the color from the &#34;default&#34; style.
        &#34;default&#34;: {
            &#34;icon&#34;: &#34;dot&#34;,
            // Support the old convention of `brackethighlighter.default`
            // for themes that already provide something.
            // As this has always been the only one we&#39;ve provided
            // by default, all the others will use region-ish colors.
            &#34;color&#34;: &#34;region.yellowish brackethighlighter.default&#34;,
            &#34;style&#34;: &#34;underline&#34;
        },

        // This particular style is used to highlight
        // unmatched bracket pairs.  It is a special
        // style.
        &#34;unmatched&#34;: {
            &#34;icon&#34;: &#34;question&#34;,
            &#34;color&#34;: &#34;region.redish&#34;,
            &#34;style&#34;: &#34;outline&#34;
        },
        // User defined region styles
        &#34;curly&#34;: {
            &#34;icon&#34;: &#34;curly_bracket&#34;,
            &#34;color&#34;: &#34;region.yellowish&#34;,
            &#34;style&#34;: &#34;underline&#34;
        },
        &#34;round&#34;: {
            &#34;icon&#34;: &#34;round_bracket&#34;,
            &#34;color&#34;: &#34;region.yellowish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        },
        &#34;square&#34;: {
            &#34;icon&#34;: &#34;square_bracket&#34;,
            &#34;color&#34;: &#34;region.yellowish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        },
        &#34;angle&#34;: {
            &#34;icon&#34;: &#34;angle_bracket&#34;,
            &#34;color&#34;: &#34;region.orangish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        },
        &#34;tag&#34;: {
            &#34;icon&#34;: &#34;tag&#34;,
            &#34;color&#34;: &#34;region.orangish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        },
        &#34;c_define&#34;: {
            &#34;icon&#34;: &#34;hash&#34;,
            &#34;color&#34;: &#34;region.yellowish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        },
        &#34;single_quote&#34;: {
            &#34;icon&#34;: &#34;single_quote&#34;,
            &#34;color&#34;: &#34;region.greenish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        },
        &#34;double_quote&#34;: {
            &#34;icon&#34;: &#34;double_quote&#34;,
            &#34;color&#34;: &#34;region.greenish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        },
        &#34;regex&#34;: {
            &#34;icon&#34;: &#34;star&#34;,
            &#34;color&#34;: &#34;region.greenish&#34;
            // &#34;style&#34;: &#34;underline&#34;
        }
    }
}
```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2020-04-22-sublime--brackethighlighter-%E9%AB%98%E4%BA%AE%E6%8B%AC%E5%8F%B7/  

