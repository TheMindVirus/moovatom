#pip install qtfaststart
"""
$> python -m qtfaststart --list "2022-10-04 19-11-45.mp4"
ftyp (32 bytes)
free (8 bytes)
mdat (3910090387 bytes)
moov (1406921 bytes)
""" # These values are sizes, not offsets

# moov header accidentally encoded into the video stream
# valid moov header found at 0xE90F3EC0

def main():
    print("__mp4_moov_atom__")
    o = 0xE90F3EBB # just find "moov" alongside "mvhd" in HxD Hex Editor
    n = 1406923 # > moov_size usually found at the end of the video file
    file = open("2022-10-04 19-11-45-duplicate-moov.mp4", "rb")
    #file = open("videoplayback (7).mp4", "rb")
    #o = 16
    file.seek(0, 2)
    sz = file.tell()
    print(sz / 1024 / 1024 / 1024, "GB")
    file.seek(0)
    #print(quick_file_scan(file, b"moov"))
    #print(granular_file_scan(file, b"moov"))
    file.seek(o)
    data = file.read(n)
    short = data[:255]
    file.close()
    
    #print(data)
    #print("".join([chr(i) for i in data]))
    #print(data.decode("raw_unicode_escape"))
    print("".join(["\\x{:02}".format(hex(i)[2:]) for i in short]))

    atom = dict()
    atom["moov_size"] = int.from_bytes(data[0:4], "big")
    atom["moov_type"] = data[4:8].decode() # "moov"
    
    atom["mvhd_size"] = int.from_bytes(data[8:12], "big")
    atom["mvhd_type"] = data[12:16].decode() # "mvhd"
    atom["mvhd_vers"] = data[16]
    atom["mvhd_flag"] = int.from_bytes(data[17:20], "big")
    atom["mvhd_cr8t"] = int.from_bytes(data[20:24], "big")
    atom["mvhd_modt"] = int.from_bytes(data[24:28], "big")
    atom["mvhd_scal"] = int.from_bytes(data[28:32], "big")
    atom["mvhd_dura"] = int.from_bytes(data[32:36], "big")
    atom["mvhd_rate"] = int.from_bytes(data[36:40], "big")
    atom["mvhd_volu"] = int.from_bytes(data[40:42], "big")
    atom["mvhd_rsvd"] = int.from_bytes(data[42:52], "big")
    atom["mvhd_mtrx"] = int.from_bytes(data[52:56], "big")
    atom["mvhd_pred"] = int.from_bytes(data[56:60], "big")
    atom["mvhd_next"] = int.from_bytes(data[60:64], "big")

    atom["trak_size"] = int.from_bytes(data[116:120], "big")
    atom["trak_type"] = data[120:124].decode() # "trak"

    atom["tkhd_size"] = int.from_bytes(data[124:128], "big")
    atom["tkhd_type"] = data[128:132].decode() # "tkhd"
    atom["tkhd_vers"] = data[132]
    atom["tkhd_flag"] = int.from_bytes(data[133:136], "big")
    atom["tkhd_cr8t"] = int.from_bytes(data[136:140], "big")
    atom["tkhd_modt"] = int.from_bytes(data[140:144], "big")
    atom["tkhd_tkid"] = int.from_bytes(data[144:148], "big")
    atom["tkhd_rsvd"] = int.from_bytes(data[148:152], "big")
    atom["tkhd_dura"] = int.from_bytes(data[152:156], "big")
    atom["tkhd_rsv2"] = int.from_bytes(data[156:164], "big")
    atom["tkhd_layr"] = int.from_bytes(data[164:166], "big")
    atom["tkhd_altg"] = int.from_bytes(data[166:168], "big")
    atom["tkhd_volu"] = int.from_bytes(data[168:170], "big")
    atom["tkhd_rsv3"] = int.from_bytes(data[170:172], "big")
    atom["tkhd_mtrx"] = int.from_bytes(data[172:174], "big") # could be larger

    atom["VIDEO_WIDTH"] = int.from_bytes(data[206:210], "big") # this is always in a random place
    atom["VIDEO_HEIGHT"] = int.from_bytes(data[210:214], "big")
    
    for key in atom.keys():
        print(str(key) + ": " + str(atom[key]))
    
    print(data[206:255])

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

if __name__ == "__main__":
    main()
