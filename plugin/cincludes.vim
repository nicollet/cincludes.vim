"====================================================================
"File: cincludes.vim
"Author: Xavier Nicollet
"Description: Vim plugin to automatically add standard headers
"todo: automatically remove standard headers.
"====================================================================

let s:cincludes_mappings = {
	\ 'open': ['sys/types.h', 'sys/stat.h', 'fcntl.h'],
	\ 'creat': ['sys/types.h', 'sys/stat.h', 'fcntl.h'],
	\ 'openat': ['sys/types.h', 'sys/stat.h', 'fcntl.h'],
	\ 'close': ['unistd.h'],
	\ 'printf': ['stdio.h'],
	\ 'fprintf': ['stdio.h'],
	\ 'dprintf': ['stdio.h'],
	\ 'sprintf': ['stdio.h'],
	\ 'snprintf': ['stdio.h'],
	\ 'vprintf': ['stdarg.h'],
	\ 'vfprintf': ['stdarg.h'],
	\ 'vdprintf': ['stdarg.h'],
	\ 'vsprintf': ['stdarg.h'],
	\ 'vsnprintf': ['stdarg.h'],
	\ 'dup': ['unistd.h'],
	\ 'dup2': ['unistd.h'],
	\ 'dup3': ['unistd.h', 'fcntl.h'],
	\ 'unlink': ['unistd.h'],
	\ 'unlinkat': ['fcntl.h', 'unistd.h'],
	\ 'opendir': ['sys/types.h', 'dirent.h'],
	\ 'fdopendir': ['sys/types.h', 'dirent.h'],
	\ 'rmdir': ['unistd.h'],
	\ 'mkdir': ['sys/stat.h', 'sys/types.h'],
	\ 'mkdirat': ['fcntl.h', 'sys/stat.h'],
	\ 'fork': ['unistd.h'],
	\ 'clone': ['sched.h'],
	\ }


if exists('g:loaded_cincludes') || &compatible
	finish
endif
let g:loaded_cincludes = 1

if v:version < 700
	echom "cincludes.vim needs vim >=7"
	finish
endif

function! s:addEntry(map, key, val)
	if !has_key(a:map, a:key)
		let a:map[a:key] = a:val
	endif
endfunction

function! s:GetIncludes()
	let l:includes = {}
	for l:line in range(0, 100)
		let l:text = getline(l:line)
		let l:inc = matchlist(l:text, '^#include <\(.*\)>')
		if l:inc != []
			call s:addEntry(l:includes, l:inc[1], l:line)
		endif
	endfor
	return l:includes
endfunction


function! s:getIncludesFromFunctions()
	let l:includes = {}
	let l:oldPos = getcurpos()
	call cursor(1,1)
	while search('\w\+\s*(', 'cpWze',10000, 1000)
		if s:IsComment(line('.'), col('.'))
			continue
		endif
		let l:function = matchlist(getline('.'), '\(\w\+\)\s*(')
		if l:function == []
			continue
		else
			let l:function = l:function[1]
		endif
		if has_key(s:cincludes_mappings, l:function)
			for l:inc in s:cincludes_mappings[l:function]
				call s:addEntry(l:includes, l:inc, l:function)
			endfor
		endif
	endwhile
	call setpos('.', l:oldPos)
	return l:includes
endfunction

function! s:IncludeToAdd()
	let l:includes = s:GetIncludes()
	let l:toAdd = {}
	let l:implicitIncludes = s:getIncludesFromFunctions()
	for l:candidate in keys(l:implicitIncludes)
		if !has_key(l:includes, l:candidate)
			call s:addEntry(l:toAdd, l:candidate, l:implicitIncludes[l:candidate])
		endif
	endfor
	return l:toAdd
endfunction

function! s:IsComment(l, c)
	if a:l > line('$')
		return 0
	endif
	let hg = join(map(synstack(a:l, a:c), 'synIDattr(v:val, "name")'), '')
	return hg =~? 'comment' ? 1 : 0
endfunction

function! s:findLine()
	call cursor(1, 1)
	let l:found = search('#include <', 'n', 10000, 1000) + 1
	" todo: what if there is only comments
	while l:found <= line('$') && s:IsComment(l:found, 1)
		let l:found += 1
	endwhile
	let l:found -= 1
	return l:found
endfunction

function! g:AddIncludes()
	if &filetype != 'c'
		return
	endif

	let l:toAdd = []
	for l:x in keys(s:IncludeToAdd())
		call add(l:toAdd, printf("#include <%s>", l:x))
	endfor
	let l:oldPos = getcurpos()
	call append(s:findLine(), l:toAdd)
	call setpos('.', l:oldPos)
endfunction

command! AddIncludes call g:AddIncludes()

