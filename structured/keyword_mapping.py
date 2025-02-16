#from _ import classified_data

def extract_selected_content(document_data, selectedheaders, unselectedheaders):
    try:
        extracted_data = []  # Final list to store selected headers and contents
        header_indices = {}  # Store indices of headers in document_data
        selected_header_indices = set()  # Track indices of selected headers

        # Ensure inputs are valid lists
        if not isinstance(document_data, list) or not isinstance(selectedheaders, list) or not isinstance(unselectedheaders, list):
            raise TypeError("Invalid input: document_data, selectedheaders, and unselectedheaders must be lists.")

        # Create a mapping of header id -> index in document_data
        for idx, entry in enumerate(document_data):
            if not isinstance(entry, dict):
                raise ValueError(f"Invalid entry at index {idx}: Expected a dictionary.")
            if "type" in entry and entry["type"] == "H" and "id" in entry:
                header_indices[entry["id"]] = idx

        # Expand selection to include all headers under the selected headers until the next equal font size header
        for header_id in selectedheaders:
            if header_id not in header_indices:
                continue  # Skip if header not found

            start_idx = header_indices[header_id]
            selected_header_indices.add(start_idx)  # Store selected header index
            extracted_section = []

            extracted_section.append(document_data[start_idx])  # Add the selected header

            # Traverse until the next equal font-sized header
            for i in range(start_idx + 1, len(document_data)):
                if document_data[i]["type"] == "H" and document_data[i]["fsize"] >= document_data[start_idx]["fsize"]:
                    break  # Stop at the next equal-sized header
                extracted_section.append(document_data[i])
                if document_data[i]["type"] == "H":
                    selected_header_indices.add(i)  # Mark automatically selected headers

            extracted_data.append(extracted_section)

        # Remove manually unselected headers and all dictionaries under them till the next equal font-sized header
        filtered_data = []
        skip_section = False

        for section in extracted_data:
            new_section = []
            for item in section:
                if item["type"] == "H" and item.get("id") in unselectedheaders:
                    skip_section = True  # Start skipping from this header
                elif item["type"] == "H" and item["fsize"] >= section[0]["fsize"]:
                    skip_section = False  # Stop skipping when reaching an equal-sized header

                if not skip_section:
                    new_section.append(item)

            if new_section:
                filtered_data.append(new_section)

        return filtered_data

    except Exception as e:
        print(f"Error in extract_selected_content: {e}")
        return []


filtered_content = extract_selected_content(classified_data, selectedheaders, unselectedheaders)

import pprint
pprint.pprint(filtered_content)
