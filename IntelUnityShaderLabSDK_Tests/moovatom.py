#pip install qtfaststart
"""
$> python -m qtfaststart --list "2022-10-04 19-11-45.mp4"
ftyp (32 bytes)
free (8 bytes)
mdat (3910090387 bytes)
moov (1406921 bytes)
"""

# moov header accidentally encoded into the video stream

def main():
    o = 774144000 # int(1406921 / 8) # or just find "moov"
    n = 1024
    file = open("2022-10-04 19-11-45.mp4", "rb")
    file.seek(o, 2)
    print(file.tell())
    print(quick_file_scan(file, b"moov"))
    print(granular_file_scan(file, b"moov"))
    print(moar_granular_file_scan(file, b"moov"))
    #print(even_moar_granular_file_scan(file, b"moov"))
    #file.seek(o)
    #data = file.read(n)
    #print(data[0:n])
    file.seek(773087232)
    data = file.read(255)
    print(data)
    file.close()

def quick_file_scan(file, term, chunk_size = 4096000, chunk_limit = 1000):
    chunk = 0
    found = False
    pos = file.tell()
    try:
        file.seek(0)
        while True:
            data = file.read(chunk_size)
            try:
                if data.index(term):
                    found = True
                    break
            except:
                pass
            if chunk >= chunk_limit:
                chunk = -1
                break
            chunk += 1
    except Exception as error:
        print(error)
        chunk = -1
    file.seek(pos)
    return chunk * chunk_size

def granular_file_scan(file, term, offset = 770048000, size = 4096, limit = 4096000):
    chunk = 0
    found = False
    pos = file.tell()
    try:
        file.seek(offset)
        while True:
            data = file.read(size)
            try:
                if data.index(term):
                    found = True
                    break
            except:
                pass
            if chunk >= limit:
                chunk = -1
                break
            chunk += 1
    except Exception as error:
        print(error)
        chunk = -1
    file.seek(pos)
    return offset + (chunk * size)

def moar_granular_file_scan(file, term, offset = 773087232, size = 255, limit = 4096000):
    chunk = 1
    found = False
    pos = file.tell()
    try:
        file.seek(offset)
        while True:
            data = file.read(size)
            try:
                if data.index(term):
                    found = True
                    break
            except:
                pass
            if chunk >= limit:
                chunk = -1
                break
            chunk += 1
    except Exception as error:
        print(error)
        chunk = 0
    file.seek(pos)
    return offset + chunk * size

def even_moar_granular_file_scan(file, term, offset = 773091328, size = 64, limit = 4096000):
    chunk = 1
    found = False
    pos = file.tell()
    try:
        file.seek(offset)
        while True:
            data = file.read(size)
            try:
                if data.index(term):
                    found = True
                    break
            except:
                pass
            if chunk >= limit:
                chunk = -1
                break
            chunk += 1
    except Exception as error:
        print(error)
        chunk = 0
    file.seek(pos)
    return chunk

"""
def file_size(handle, chunk_size = 1 * 1024 * 1024 * 1024):
    i = 0
    j = 0
    jprev = 0
    try:
        while True:
            file.seek(chunk_size)
            i += chunk_size
            j = file.tell()
            print(i, j)
            if j == jprev:
                break
            jprev = j
    except:
        pass
    i = j
    file.seek(0)
    try:
        while True:
            file.seek(chunk_size)
            i -= 1
            j = file.tell()
            print(i, j)
            if j != jprev:
                break
            jprev = j
    except:
        pass
    return j
""" # Neural Method probably not required

if __name__ == "__main__":
    main()
