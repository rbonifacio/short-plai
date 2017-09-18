from sys import argv

if __name__ == '__main__':
    if len(argv) < 2:
        print(
            """O programa deve ser utilizado na forma:
            python <nome do programa> <arquivo1.lhs> <arquivo2.lhs> <...>""")
        exit(-1)

    for filename in argv[1:]:
    	if filename[-4:] != ".lhs":
    		print("Nome do arquivo <%s> invalido" % filename)
    	else:
	        res = ""
	        with open(filename, 'r') as f:
	            comment = True
	            ln = f.readline()
	            while ln != "":
	                if comment:
	                    if "\\begin{code}" in ln:
	                        comment = False
	                    #else:
	                    #    res += '-- ' + ln
	                else:
	                    if "\\end{code}" in ln:
	                        comment = True
	                    else:
	                        res += ln
	                
	                ln = f.readline()
	        res_filename = filename[:-3] + 'hs'
	        with open(res_filename, 'w') as f:
	            f.write(res)
