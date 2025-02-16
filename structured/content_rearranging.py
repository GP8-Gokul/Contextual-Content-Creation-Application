from sentence_transformers import SentenceTransformer, util


model = SentenceTransformer("all-mpnet-base-v2")

def check_continuity(previous_text, current_text, threshold=0.75):
    """
    Determines if the current text is continuous with the previous text using sentence similarity.
    """
    prev_embedding = model.encode(previous_text, convert_to_tensor=True)
    curr_embedding = model.encode(current_text, convert_to_tensor=True)

    similarity_score = util.pytorch_cos_sim(prev_embedding, curr_embedding).item()
    return similarity_score >= threshold

def reorder_non_continuous_texts(sectioned_data):
    """
    Reorders non-continuous texts by moving them to the end of each section.
    Ensures headers and their corresponding content are moved together.
    """
    for section in sectioned_data:
        continuous_texts = []
        non_continuous_texts = []
        previous_text = ""

        i = 0
        while i < len(section):
            entry = section[i]

            if entry["type"] == "H":
                # If there's previous text, check continuity
                if previous_text and not check_continuity(previous_text, entry["text"]):
                    non_continuous_texts.append(entry)

                    # Move all its associated content as well
                    j = i + 1
                    while j < len(section) and section[j]["type"] == "C":
                        non_continuous_texts.append(section[j])
                        j += 1

                    i = j  # Skip past the moved content
                    continue

            elif entry["type"] == "C":
                if previous_text and not check_continuity(previous_text, entry["text"]):
                    non_continuous_texts.append(entry)
                    i += 1
                    continue

            continuous_texts.append(entry)
            previous_text = entry["text"]  # Keep only the last seen text for comparison
            i += 1

        # Append non-continuous texts at the end
        section.clear()
        section.extend(continuous_texts + non_continuous_texts)

    return sectioned_data

# Process the document structure
reordered_data = reorder_non_continuous_texts(document_data)
'''
# Print output
for section in reordered_data:
    print("\nProcessed Section:")
    for item in section:
        print(f"{item['type']}: {item['text']}")
'''
