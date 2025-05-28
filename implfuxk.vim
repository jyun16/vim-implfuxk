function! GetInterfaceName()
	let l = getline('.')
	if l =~ '\<interface\>'
		let tokens = split(l)
		let idx = index(tokens, 'interface')
		if idx >= 0 && idx+1 < len(tokens)
			return substitute(tokens[idx+1], '{', '', '')
		endif
	endif
	return expand('<cword>')
endfunction

function! ImplFuxk()
	let word = GetInterfaceName()
	let pattern = 'implements ' . word
	let taglines = systemlist('grep "' . pattern . '" tags')
	let results = []
	for line in taglines
		let fields = split(line, '\t')
		if len(fields) >= 3 && match(fields[2], 'implements ' . word . '[ ,{]') != -1
			call add(results, line)
		endif
	endfor
	if len(results) == 0
		echo "No Impl found: " . pattern
		return
	endif
	if len(results) == 1
		let fields = split(results[0], '\t')
		execute 'tag ' . fields[0]
		return
	endif
	let qf = []
	for line in results
		let fields = split(line, '\t')
		if len(fields) >= 2
			call add(qf, {'filename': fields[1], 'lnum': 1, 'text': fields[0]})
		endif
	endfor
	call setqflist(qf, 'r')
	copen
endfunction

nnoremap <silent> <C-q> :call ImplFuxk()<CR>
