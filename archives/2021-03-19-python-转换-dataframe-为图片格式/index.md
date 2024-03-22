# Python 转换 DataFrame 为图片格式


将 `DataFrame` 输出为图片形式，方便监控。
&lt;!--more--&gt;


```python
# -*- coding: utf-8 -*-
# @Author: “williamlfang”
# @Date:   2021-03-19 15:18:19
# @Last Modified by:   “williamlfang”
# @Last Modified time: 2021-03-19 16:18:32

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import six
from matplotlib.ticker import FormatStrFormatter

def render_mpl_table(data, savepath, title = &#34;&#34;, col_width=2.0, row_height=0.625, font_size=12,
                     header_color=&#39;#40466e&#39;, row_colors=[&#39;#f1f1f2&#39;, &#39;w&#39;], edge_color=&#39;w&#39;,
                     bbox=[0, 0, 1, 1], header_columns=0,
                     ax=None, **kwargs):
    if ax is None:
        size = (np.array([0,1]) &#43; np.array(data.shape[::-1]) &#43; np.array([0, 1])) * np.array([col_width, row_height])
        fig, ax = plt.subplots(figsize=size)
        ax.set_title(title, fontdict={&#39;fontsize&#39;: 15, &#39;fontweight&#39;: &#39;bold&#39;, &#39;color&#39;: header_color, &#39;horizontalalignment&#39;:&#39;center&#39;})
        ax.yaxis.set_major_formatter(FormatStrFormatter(&#39;%g&#39;))
        # fig.tight_layout()
        ax.axis(&#39;off&#39;)

    mpl_table = ax.table(cellText=data.values, bbox=bbox, colLabels=data.columns, **kwargs)

    mpl_table.auto_set_font_size(False)
    mpl_table.set_fontsize(font_size)

    for k, cell in  six.iteritems(mpl_table._cells):
        cell.set_edgecolor(edge_color)
        if k[0] == 0 or k[1] &lt; header_columns:
            cell.set_text_props(weight=&#39;bold&#39;, color=&#39;w&#39;)
            cell.set_facecolor(header_color)
        else:
            cell.set_facecolor(row_colors[k[0]%len(row_colors) ])
    # return ax
    plt.savefig(savepath)
    plt.close()

if __name__ == &#34;__main__&#34;:
    df = pd.DataFrame()
    df[&#39;date&#39;] = [&#39;2016-04-01&#39;, &#39;2016-04-02&#39;, &#39;2016-04-03&#39;]
    df[&#39;calories&#39;] = [2200.343332424, 2100.34, 1500]
    df[&#39;sleep hours&#39;] = [2200, 2100, 1500]
    df[&#39;gym&#39;] = [True, False, False]

    # ==========================================================================
    render_mpl_table(df, savepath= &#39;/tmp/dfm.png&#39;, title = &#34;My Title&#34;, header_columns=0, col_width=2.0)
    # ==========================================================================

```



---

> 作者: william  
> URL: https://williamlfang.github.io/archives/2021-03-19-python-%E8%BD%AC%E6%8D%A2-dataframe-%E4%B8%BA%E5%9B%BE%E7%89%87%E6%A0%BC%E5%BC%8F/  

