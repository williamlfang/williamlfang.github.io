# coc settings.json


`coc.vim` 配置，实现自动跳出补全功能。

- 注释掉：`suggest.noselect`
- 注释掉：`suggest.autoTrigger`

```bash
  // 不能设置
  // &#34;suggest.noselect&#34;: false,
  // &#34;suggest.autoTrigger&#34;: false,
  // &#34;suggest.triggerAfterInsertEnter&#34;: true
```

&lt;!--more--&gt;


```json
{
  // Enable preselect feature on neovim, default: `true`
  &#34;suggest.enablePreselect&#34;: true,
  // Add preview option to `completeopt`, default: `false`
  &#34;suggest.enablePreview&#34;: true,
  // completion automatically select the first completed
  // 不能设置
  // &#34;suggest.noselect&#34;: false,
  // &#34;suggest.autoTrigger&#34;: false,
  // &#34;suggest.triggerAfterInsertEnter&#34;: true
  &#34;diagnostic.checkCurrentLine&#34;: true,
  // min word for trigger preview
  &#34;suggest.minTriggerInputLength&#34;: 1,
  // Target to show hover information, default is floating window when possible.
  &#34;coc.preferences.hoverTarget&#34;: &#34;preview&#34;,
  // Auto close preview window on cursor move.,  default: `true`
  &#34;coc.preferences.previewAutoClose&#34;: true,

  // Coc.Prettier ---------------------------------------------------------------
  &#34;prettier.singleQuote&#34;: true,
  &#34;prettier.trailingComma&#34;: &#34;all&#34;,
  &#34;prettier.bracketSpacing&#34;: false,

  // Coc.Python -----------------------------------------------------------------
  &#34;python.linting.pylintEnabled&#34;: false,
  &#34;python.linting.enabled&#34;: true,
  &#34;python.pythonPath&#34;: &#34;/home/william/anaconda3/bin/python3&#34;,
  &#34;pyright.inlayHints.variableTypes&#34;: false,
  &#34;python.linting.flake8Enabled&#34;: true,
  &#34;python.linting.flake8Args&#34;: [
      &#34;--max-line-length=120&#34;,
      &#34;--ignore=E203,E221,E251,E266,E302,E305,E402,W503,F401,F403,F405&#34;
    ],
  // https://github.com/fannheyward/coc-pyright/blob/master/package.json
  &#34;python.analysis.diagnosticSeverityOverrides&#34;: {
    &#34;reportWildcardImportFromLibrary&#34;: &#34;none&#34;,
    &#34;reportOptionalMemberAccess&#34;: &#34;none&#34;
  }

  // coc.markdown
  &#34;markdownlint.config&#34;: {
      &#34;default&#34;: true,
      &#34;line_length&#34;: false,
      &#34;no-inline-html&#34;: { &#34;allowed_elements&#34;: [&#34;pre&#34;] },
      &#34;ul-indent&#34;: { &#34;indent&#34;: 4 }
  },
  //coc.clangd
  &#34;clangd.path&#34;: &#34;~/.config/coc/extensions/coc-clangd-data/install/16.0.2/clangd_16.0.2/bin/clangd&#34;
}
```


---

> 作者: william  
> URL: https://williamlfang.github.io/2023-06-08-coc-settings.json/  

