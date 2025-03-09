def convert_to_chunks(lines, group_size=5, overlap=1):
    chunks = []
    i = 0
    
    while i < len(lines):

        chunk = lines[i : i + group_size]
        
        chunks.append(" ".join(chunk))
        
        i += group_size - overlap
    
    return chunks