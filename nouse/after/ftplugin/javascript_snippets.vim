if !exists('loaded_snippet') || &cp
    finish
endif

let st = g:snip_start_tag
let et = g:snip_end_tag
let cd = g:snip_elem_delim

exec "Snippet proto ".st."className".et.".prototype.".st."methodName".et." = function(".st.et.")<CR>{<CR>".st.et."<CR>};<CR>".st.et
exec "Snippet fun /**<CR>* ".st.et."<CR>* @param {} <CR>*/<CR>function ".st."functionName".et."(".st.et."){<CR>".st.et."<CR>}<CR>".st.et
exec "Snippet fn function(".st.et."){<CR>".st.et."<CR>};<CR>".st.et
exec "Snippet if if (".st.et.") {<CR>".st.et."<CR>} else {<CR>".st.et."<CR>}<CR>".st.et
exec "Snippet for for (var ".st."i".et." = ".st."0".et.", ".st."l".et." = ".st."array".et.".length; ".st."i".et." < ".st."l".et."; ".st."i".et."++) {<CR>".st.et."<CR>}<CR>".st.et
exec "Snippet $ $(".st."selector".et.").".st."method".et."(".st.et.")".st.et
exec "Snippet $( $(function(){<CR><CR>".st.et."<CR><CR>});<CR>".st.et
exec "Snippet settime setTimeout(function(){ ".st.et."}, ".st.et.");<CR>".st.et
exec "Snippet setinter setInterval(function(){ ".st.et."}, ".st.et.");<CR>".st.et

