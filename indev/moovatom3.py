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
    #file = open("2022-10-04 19-11-45-duplicate-moov.mp4", "rb")
    #file = open("videoplayback (7).mp4", "rb")
    #o = 16
    file = open("2022-10-03 20-12-41.mp4", "rb")
    o = 0x8CCDBE
    file.seek(0, 2)
    sz = file.tell()
    print(sz / 1024 / 1024 / 1024, "GB")
    file.seek(0)
    #print(quick_file_scan(file, b"moov"))
    #print(granular_file_scan(file, b"moov"))
    file.seek(o)
    data = file.read(n)
    short = data[:512]
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

    atom["mdia_size"] = int.from_bytes(data[252:256], "big")
    atom["mdia_type"] = data[256:260].decode() # "mdia"

    atom["mdhd_size"] = int.from_bytes(data[260:264], "big")
    atom["mdhd_type"] = data[264:268].decode() # "mdhd"
    atom["mdhd_vers"] = data[268]
    atom["mdhd_flag"] = int.from_bytes(data[269:272], "big")
    atom["mdhd_cr8t"] = int.from_bytes(data[272:276], "big")
    atom["mdhd_modt"] = int.from_bytes(data[276:280], "big")
    atom["mdhd_scal"] = int.from_bytes(data[280:284], "big")
    atom["mdhd_dura"] = int.from_bytes(data[284:288], "big")
    atom["mdhd_lang"] = int.from_bytes(data[288:290], "big")
    atom["mdhd_pred"] = int.from_bytes(data[290:292], "big")

    atom["hdlr_size"] = int.from_bytes(data[292:296], "big")
    atom["hdlr_type"] = data[296:300].decode() # "hdlr"
    atom["hdlr_vers"] = data[300]
    atom["hdlr_flag"] = int.from_bytes(data[301:304], "big")
    atom["hdlr_comp"] = data[304:308].decode()
    atom["hdlr_coms"] = data[308:312].decode()
    atom["hdlr_name"] = data[324:336].decode()

    atom["minf_size"] = int.from_bytes(data[337:341], "big")
    atom["minf_type"] = data[341:345].decode()

    atom["vmhd_size"] = int.from_bytes(data[345:349], "big")
    atom["vmhd_type"] = data[349:354].decode()
    atom["vmhd_vers"] = data[354]
    atom["vmhd_flag"] = int.from_bytes(data[355:359], "big")
    atom["vmhd_mode"] = int.from_bytes(data[359:361], "big")
    atom["vmhd_opcr"] = int.from_bytes(data[361:362], "big")
    atom["vmhd_opcg"] = int.from_bytes(data[362:363], "big")
    atom["vmhd_opcb"] = int.from_bytes(data[363:364], "big")
    
    atom["dinf_size"] = int.from_bytes(data[365:369], "big")
    atom["dinf_type"] = data[369:373].decode()

    atom["dref_size"] = int.from_bytes(data[373:377], "big")
    atom["dref_type"] = data[377:381].decode()
    atom["dref_vers"] = data[381]
    atom["dref_ntry"] = int.from_bytes(data[382:386], "big")
    atom["dref_dref"] = int.from_bytes(data[386:390], "big") # could be larger

    atom["url _size"] = int.from_bytes(data[389:393], "big")
    atom["url _type"] = data[393:397].decode()
    atom["url _vers"] = data[397]
    atom["url _flag"] = int.from_bytes(data[398:402], "big")

    atom["stbl_size"] = int.from_bytes(data[401:405], "big")
    atom["stbl_type"] = data[405:409].decode()

    atom["stsd_size"] = int.from_bytes(data[409:413], "big")
    atom["stsd_type"] = data[413:417].decode()
    atom["stsd_vers"] = data[417]
    atom["stsd_flag"] = int.from_bytes(data[418:421], "big")
    atom["stsd_ntry"] = int.from_bytes(data[421:425], "big")
    atom["stsd_sdsz"] = int.from_bytes(data[425:429], "big")
    atom["stsd_form"] = data[429:433].decode()
    atom["stsd_rsvd"] = int.from_bytes(data[433:439], "big")
    atom["stsd_refi"] = int.from_bytes(data[439:441], "big")
    atom["stsd_pred"] = int.from_bytes(data[441:449], "big")
    atom["stsd_rsv2"] = int.from_bytes(data[449:457], "big")
    atom["stsd_vidw"] = int.from_bytes(data[457:459], "big")
    atom["stsd_vidh"] = int.from_bytes(data[459:461], "big")
    atom["stsd_resw"] = int.from_bytes(data[461:463], "big") # Odd Offsets
    atom["stsd_resh"] = int.from_bytes(data[465:467], "big") # Should be 72
    atom["stsd_rsv3"] = int.from_bytes(data[467:469], "big") # Should be 0
    atom["stsd_fcnt"] = int.from_bytes(data[471:475], "big") # Should be 1

    #reach stsz, maybe also do stco and udta
    
    for key in atom.keys():
        print(str(key) + ": " + str(atom[key]))
    
    #print(data[256:512])
    print(data[465:512])

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
