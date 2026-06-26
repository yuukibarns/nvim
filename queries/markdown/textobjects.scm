; (atx_heading
;   heading_content: (_) @class.inner) @class.outer
;
; (setext_heading
;   heading_content: (_) @class.inner) @class.outer
;
; (thematic_break) @class.outer

(fenced_code_block
  (code_fence_content) @codeblock.inner) @codeblock.outer

; [
;   (paragraph)
;   (list)
; ] @block.outer
