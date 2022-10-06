# WARNING: Does not find in-data duplicates of atoms, only in a short range
#          You need to specify the offsets manually in case it is incorrect

def main():
    print("__mp4_moov_atom__")
    file = open("2022-10-04 19-11-45-duplicate-moov.mp4", "rb")
    #file = open("2022-10-03 20-12-41.mp4", "rb")
    
    file.seek(0, 2)
    file_size = file.tell()
    print(file_size / 1024 / 1024 / 1024, "GB")
    file.seek(0)
    
    chunk_size = 100 * 1024 * 1024
    print(chunk_size / 1024 / 1024, "MB")
    chunks = file_size / chunk_size
    rounded = round(chunks)
    remainder = chunks - rounded
    chunks = rounded if remainder <= 0.0 else rounded + 1
    print(chunks, "Chunks")

    #atoms = ["mdat"]
    atoms = \
    [
        "moov", "mvhd", "trak", "tkhd", "mdia", "mdhd", "hdlr", "minf",
        "vmhd", "dinf", "dref", "url", "stbl", "stsd", "avc1", "avcC",
        "stts", "stss", "ctts", "stsc", "stsz", "stco", "mdat"
    ]
    
    report = dict()
    atom_count = len(atoms)
    for i in range(0, atom_count):
        report[atoms[i]] = []

    offset = 0
    for j in range(0, chunks):
        file.seek(offset)
        data1 = file.read(chunk_size)
        offset2 = offset + int(chunk_size / 2)
        file.seek(offset2)
        data2 = file.read(chunk_size)
        for i in range(0, atom_count):
            atom = atoms[i].encode()
            report[atoms[i]] += scan(data1, atom, offset, chunk_size)
            report[atoms[i]] += scan(data2, atom, offset2, chunk_size)
        offset += chunk_size
        print("###CHUNK[{}]###\n{}".format(j, report))
    for key in report.keys():
        report[key] = remove_duplicates(report[key])
    print("###FINAL_REPORT###\n{}".format(report))
    file.close()
    print("Done!")

def scan(data, term, offset = 0, size = 4096, limit = 4294967296):
    start = 0
    found = []
    while start < size:
        try:
            pos = data.index(term, start)
            if pos > -1:
                found.append(hex(offset + pos))
            else:
                break
        except Exception as error:
            break
        start = pos + 1
    return found

def remove_duplicates(data):
    seen = []
    for item in data:
        if item not in seen:
            seen.append(item)
    return seen

if __name__ == "__main__":
    main()
