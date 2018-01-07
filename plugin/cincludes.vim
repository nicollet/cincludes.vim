"====================================================================
"File: cincludes.vim
"Author: Xavier Nicollet
"Description: Vim plugin to automatically add standard headers
"todo: automatically remove standard headers.
"====================================================================

" if exists('g:loaded_cincludes') || &compatible
" 	finish
" endif
" let g:loaded_cincludes = 1
"
" if v:version < 700
" 	echom "cincludes.vim needs vim >=7"
" 	finish
" endif


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
	\ 'link': ['unistd.h'],
	\ 'unlinkat': ['fcntl.h', 'unistd.h'],
	\ 'opendir': ['sys/types.h', 'dirent.h'],
	\ 'fdopendir': ['sys/types.h', 'dirent.h'],
	\ 'rmdir': ['unistd.h'],
	\ 'mkdir': ['sys/stat.h', 'sys/types.h'],
	\ 'mkdirat': ['fcntl.h', 'sys/stat.h'],
	\ 'fork': ['unistd.h'],
	\ 'clone': ['sched.h'],
	\ 'getopt': ['unistd.h'],
	\ 'getopt_long': ['getopt.h'],
	\ 'getopt_long_only': ['getopt.h'],
	\ '_exit': ['unistd.h'],
	\ 'exit': ['stdlib.h'],
	\ 'read': ['unistd.h'],
	\ 'write': ['unistd.h'],
	\ 'readv': ['uio.h'],
	\ 'writev': ['uio.h'],
	\ 'preadv': ['uio.h'],
	\ 'pwritev': ['uio.h'],
	\ 'preadv2': ['uio.h'],
	\ 'pwritev2': ['uio.h'],
	\ 'utime': ['utime.h'],
	\ 'utimes': ['sys/time.h'],
	\ 'futimes': ['sys/time.h'],
	\ 'lutimes': ['sys/time.h'],
	\ 'utimensat': ['sys/stat.h'],
	\ 'futimens': ['sys/stat.h'],
	\ 'chown': ['unistd.h'],
	\ 'lchown': ['unistd.h'],
	\ 'fchown': ['unistd.h'],
	\ 'access': ['unistd.h'],
	\ 'umask': ['sys/stat.h'],
	\ 'chmod': ['sys/stat.h'],
	\ 'fchmod': ['sys/stat.h'],
	\ 'setxattr': ['sys/xattr.h'],
	\ 'lsetxattr': ['sys/xattr.h'],
	\ 'fsetxattr': ['sys/xattr.h'],
	\ 'getxattr': ['sys/xattr.h'],
	\ 'lgetxattr': ['sys/xattr.h'],
	\ 'fgetxattr': ['sys/xattr.h'],
	\ 'removexattr': ['sys/xattr.h'],
	\ 'lremovexattr': ['sys/xattr.h'],
	\ 'fremovexattr': ['sys/xattr.h'],
	\ 'listxattr': ['sys/xattr.h'],
	\ 'llistxattr': ['sys/xattr.h'],
	\ 'flistxattr': ['sys/xattr.h'],
	\ 'tmpfile': ['stdio.h'],
	\ 'tmpnam': ['stdio.h'],
	\ 'tempnam': ['stdio.h'],
	\ 'system': ['stdlib.h'],
	\ 'rename': ['stdlib.h'],
	\ 'symlink': ['unistd.h'],
	\ 'readlink': ['unistd.h'],
	\ 'remove': ['stdio.h'],
	\ 'readdir': ['dirent.h'],
	\ 'rewinddir': ['dirent.h'],
	\ 'closedir': ['dirent.h'],
	\ 'dirfd': ['dirent.h'],
	\ 'readdir_r': ['dirent.h'],
	\ 'offsetof': ['stddef.h'],
	\ 'getcwd': ['unistd.h'],
	\ 'chdir': ['unistd.h'],
	\ 'fchdir': ['unistd.h'],
	\ 'chroot': ['unistd.h'],
	\ 'realpath': ['stdlib.h'],
	\ 'dirname': ['libgen.h'],
	\ 'basename': ['libgen.h'],
	\ 'inotify_init': ['sys/inotify.h'],
	\ 'inotify_add_watch': ['sys/inotify.h'],
	\ 'inotify_rm_watch': ['sys/inotify.h'],
	\ 'strcmp': ['string.h'],
	\ 'strncmp': ['string.h'],
	\ 'signal': ['signal.h'],
	\ 'sleep': ['unistd.h'],
	\ 'pause': ['unistd.h'],
	\ 'kill': ['signal.h'],
	\ 'raise': ['signal.h'],
	\ 'killpg': ['signal.h'],
	\ 'strsignal': ['string.h'],
	\ 'psignal': ['signal.h'],
	\ 'sigemptyset': ['signal.h'],
	\ 'sigfillset': ['signal.h'],
	\ 'sigaddset': ['signal.h'],
	\ 'sigdelset': ['signal.h'],
	\ 'sigismember': ['signal.h'],
	\ 'sigandset': ['signal.h'],
	\ 'sigorset': ['signal.h'],
	\ 'sigisemptyset': ['signal.h'],
	\ 'sigprocmask': ['signal.h'],
	\ 'sigpending': ['signal.h'],
	\ 'sigaction': ['signal.h'],
	\ }

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


" function! s:getIncludesFromFunctions()
" 	let l:includes = {}
" 	let l:oldPos = getcurpos()
" 	call cursor(1,1)
" 	while search('\w\+\s*(', 'cpWze',10000, 1000)
" 		if s:IsComment(line('.'), col('.'))
" 			continue
" 		endif
" 		let l:function = matchlist(getline('.'), '\(\w\+\)\s*(')
" 		if l:function == []
" 			continue
" 		else
" 			let l:function = l:function[1]
" 		endif
" 		echom l:function
" 		if has_key(s:cincludes_mappings, l:function)
" 			for l:inc in s:cincludes_mappings[l:function]
" 				call s:addEntry(l:includes, l:inc, l:function)
" 			endfor
" 		endif
" 	endwhile
" 	call setpos('.', l:oldPos)
" 	return l:includes
" endfunction

function! s:getIncludesFromFunctions()
	let l:includes = {}
	let l:oldPos = getcurpos()
	call cursor(1,1)
	while search('\w\+\s*(', 'cpWze',10000, 1000)
		if s:IsComment(line('.'), col('.'))
			continue
		endif

		let l:funcs=[]
		let l:line = getline('.')
		call substitute(l:line, '\(\w\+\)\s*(', '\=add(l:funcs, submatch(1))', "g" )

		for l:function in l:funcs
			if has_key(s:cincludes_mappings, l:function)
				for l:inc in s:cincludes_mappings[l:function]
					call s:addEntry(l:includes, l:inc, l:function)
				endfor
			endif
		endfor
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

