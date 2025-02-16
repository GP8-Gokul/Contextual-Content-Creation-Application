import torch
from transformers import pipeline
import re
#from _ import keywords

def load_classifier():
    device = 0 if torch.cuda.is_available() else -1
    try:
        return pipeline("zero-shot-classification", model="facebook/bart-large-mnli", device=device)
    except Exception as e:
        print(f"Error loading model: {e}")
        return None

def is_related(classifier, text, keyword, threshold=0.75):
    try:
        result = classifier(text, [keyword])
        return result["scores"][0] >= threshold
    except Exception as e:
        print(f"Error in classification: {e}")
        return False

def extract_relevant_content(document_data, keywords):
    try:
        classifier = load_classifier()
        if classifier is None:
            return ""

        keyword_groups = {keyword: [] for keyword in keywords}  # Dictionary to store related texts per keyword
        i = 0
        while i < len(document_data):
            entry = document_data[i]
            text = entry["text"]
            related_keywords = []

            for keyword in keywords:
                if is_related(classifier, text, keyword):
                    related_keywords.append(keyword)
            
            if not related_keywords and i + 1 < len(document_data):
                combined_text = text + " " + document_data[i + 1]["text"]
                for keyword in keywords:
                    if is_related(classifier, combined_text, keyword):
                        related_keywords.append(keyword)
                        keyword_groups[keyword].append(entry)  # Append original entry
                        keyword_groups[keyword].append(document_data[i + 1])  # Append next entry
                        i += 1  # Skip next entry since it's already added
                        break
            
            for keyword in related_keywords:
                keyword_groups[keyword].append(entry)
            
            i += 1

        output = ""
        for keyword, entries in keyword_groups.items():
            if entries:
                output += f"{keyword} →\n"
                for entry in entries:
                    text = entry["text"]
                    if entry["type"] == "H":  # If it's a header, add a colon
                        output += f"{text}:\n"
                    else:
                        output += f"{text}\n"
                output += "\n"  # Extra line between keywords

        return output.strip()
    
    except Exception as e:
        print(f"Error in extract_relevant_content: {e}")
        return ""
'''
# Example Data
document_data = [
{'type': 'C', 'fsize': 10, 'text': 'onsider the following situations of daily life and think what happens. milk is left at room temperature during summers. an iron tawa/pan/nail is left exposed to humid atmosphere. food gets digested in our body. In all the above situations, the nature and the identity of the initial. substance have somewhat changed. We have already learnt about physical. and chemical changes of matter in our previous classes. change occurs, we can say that a chemical reaction has taken place. You may perhaps be wondering as to what is actually meant by a. How do we come to know that a chemical reaction. has taken place? Let us perform some activities to find the answer to'}
,{'type': 'H', 'fsize': 9, 'text': 'Burning of a magnesium ribbon in air and collection of magnesium. oxide in a watch-glass', 'id': 1}
,{'type': 'C', 'fsize': 10, 'text': 'would be better if students. Clean a magnesium ribbon. about 3-4 cm long by rubbing. Hold it with a pair of tongs. Burn it using a spirit lamp or. burner and collect the ash so. formed in a watch-glass as. magnesium ribbon keeping it. away as far as possible from. What do you observe?'}
,{'type': 'H', 'fsize': 10, 'text': '“Facts are not science — as the dictionary is not literature', 'id': 2}
,{'type': 'H', 'fsize': 9, 'text': 'gas by the action of. dilute sulphuric acid on', 'id': 3}
,{'type': 'C', 'fsize': 10, 'text': 'From the above three activities, we can say that any of. the following observations helps us to determine whether. a chemical reaction has taken place –. evolution of a gas. As we observe the changes around us, we can see. that there is a large variety of chemical reactions taking. We will study about the various types. of chemical reactions and their symbolic representation. Take a few zinc granules in a conical flask or a test tube. Add dilute hydrochloric acid or sulphuric acid to this. Handle the acid with care. Do you observe anything happening around the zinc. Touch the conical flask or test tube. Is there any change in. solution in a test. 1 can be described as – when a magnesium ribbon is burnt in. oxygen, it gets converted to magnesium oxide. This description of a. chemical reaction in a sentence form is quite long. It can be written in a. The simplest way to do this is to write it in the form of a. The word-equation for the above reaction would be –. The substances that undergo chemical change in the reaction (1. magnesium and oxygen, are the reactants. The new substance is. magnesium oxide, formed during the reaction, as a product. A word-equation shows change of reactants to products through an. arrow placed between them. The reactants are written on the left-hand. side (LHS) with a plus sign (+) between them. written on the right-hand side (RHS) with a plus sign (+) between them. The arrowhead points towards the products, and shows the direction of. You must have observed that magnesium ribbon burns with a. dazzling white flame and changes into a white powder. It is formed due to the reaction between magnesium. and oxygen present in the air'}
,{'type': 'H', 'fsize': 8, 'text': 'Chemical Reactions and Equations', 'id': 4}
,{'type': 'C', 'fsize': 14, 'text': '1 Writing a Chemical Equation'}
,{'type': 'C', 'fsize': 10, 'text': 'Is there any other shorter way for representing chemical equations?. Chemical equations can be made more concise and useful if we use. chemical formulae instead of words. A chemical equation represents a. If you recall formulae of magnesium, oxygen and. magnesium oxide, the above word-equation can be written as –. Count and compare the number of atoms of each element on the. LHS and RHS of the arrow. Is the number of atoms of each element the. same on both the sides? If yes, then the equation is balanced. then the equation is unbalanced because the mass is not the same on. both sides of the equation. Such a chemical equation is a skeletal. chemical equation for a reaction. 2) is a skeletal chemical. equation for the burning of magnesium in air'}
,{'type': 'C', 'fsize': 14, 'text': '2 Balanced Chemical Equations'}
,{'type': 'C', 'fsize': 10, 'text': 'Recall the law of conservation of mass that you studied in Class IX; mass. can neither be created nor destroyed in a chemical reaction. total mass of the elements present in the products of a chemical reaction. has to be equal to the total mass of the elements present in the reactants. In other words, the number of atoms of each element remains the. same, before and after a chemical reaction. Hence, we need to balance a. Is the chemical Eq. 2) balanced? Let us. learn about balancing a chemical equation step by step. The word-equation for Activity 1. 3 may be represented as –. Zinc + Sulphuric acid. Zinc sulphate + Hydrogen. The above word-equation may be represented by the following. Let us examine the number of atoms of different elements on both. sides of the arrow. Number of atoms in. As the number of atoms of each element is the same on both sides of. 3) is a balanced chemical equation. Let us try to balance the following chemical equation –'}
,{'type': 'C', 'fsize': 10, 'text': 'To balance a chemical equation, first draw boxes around each. Do not change anything inside the boxes while balancing the. List the number of atoms of different elements present in the. To equalise the number of atoms, it must be remembered that we. cannot alter the formulae of the compounds or elements involved in the. For example, to balance oxygen atoms we can put coefficient. ‘4’ as 4 H. O and not H. Now the partly balanced equation. Fe and H atoms are still not balanced. Pick any of these elements. Let us balance hydrogen atoms in the partly balanced. To equalise the number of H atoms, make the number of molecules. of hydrogen as four on the RHS. It is often convenient to start balancing with the compound. that contains the maximum number of atoms. It may be a reactant or a. In that compound, select the element which has the maximum. Using these criteria, we select Fe. There are four oxygen atoms on the RHS and only one on. To balance the oxygen atoms –. The equation would be –. Fe   +   4   H. 8 (in 4 H'}
,{'type': 'H', 'fsize': 8, 'text': 'Chemical Reactions and Equations', 'id': 5}
,{'type': 'C', 'fsize': 10, 'text': 'To equalise Fe, we take three atoms of Fe on the LHS. Finally, to check the correctness of the balanced equation, we. count atoms of each element on both sides of the equation. The numbers of atoms of elements on both sides of Eq. This equation is now balanced. This method of balancing chemical. equations is called hit-and-trial method as we make trials to balance. the equation by using the smallest whole number coefficient'}
,{'type': 'H', 'fsize': 10, 'text': 'Writing Symbols of Physical States. Writing Symbols of Physical States. Writing Symbols of Physical States. Writing Symbols of Physical States. Writing Symbols of Physical States', 'id': 6}
]

keywords = ["chemical equations", "law of mass"]
'''
formatted_output = extract_relevant_content(document_data, keywords)
#print(formatted_output)

