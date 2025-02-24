from transformers import pipeline

# Load the Mistral model for text generation
generator = pipeline("text-generation", model="mistralai/Mistral-7B-Instruct-v0.1", device_map="auto")

def refine_text(keyword, extracted_text):
    prompt = f"""
    You are a helpful AI that refines extracted text. The given text contains information about "{keyword}".
    Clean and refine it by:
    - Removing unnecessary details, equations, and redundant information.
    - Keeping only relevant and structured sentences.

    Extracted Text:
    {extracted_text}

    Refined Output:
    """

    response = generator(prompt, max_length=500, do_sample=True)[0]["generated_text"]
    return response

# Example input
keyword = "corrosion"
extracted_text = """CH OH(l)
6CO (aq)
12H O(l)
C H O (aq)
Sunlight Chlorophyll
(A) and (B) [Fig. 1.8 (b)].
Also, compare the colour of the iron nails
dipped in the copper sulphate solution
with the one kept aside [Fig. 1.8 (b)].
Figure 1.8
Heat
2CuO
If hydrogen gas is passed over this heated material (CuO), the black
coating on the surface turns brown as the reverse reaction takes place
and copper is obtained. CuO +H Cu+H O
and changes into a white substance, magnesium oxide. Is magnesium being oxidised or
reduced in this reaction? 1.3.1 Corrosion
You must have observed that iron articles are shiny when new, but get
coated with a reddish brown powder when left for some time. This process
is commonly known as rusting of iron. Some other metals also get
process is called corrosion. The black coating on silver and the green
coating on copper are other examples of corrosion.
Corrosion causes damage to car bodies, bridges, iron railings, ships
and to all objects made of metals, specially those of iron. Corrosion of
iron is a serious problem. Every year an enormous amount of money is
spent to replace damaged iron. You will learn more about corrosion in Chapter 3.
1.3.2 Rancidity
Have you ever tasted or smelt the fat/oil containing food materials left
for a long time?
Name the element ‘X’ and the black coloured compound formed.
Why do we apply paint on iron articles?
Oil and fat containing food items are flushed with nitrogen. Why?
Explain the following terms with one example each. Corrosion Rancidity
Group  Activity Perform the following activity."""

# Run Mistral to refine the text
cleaned_text = refine_text(keyword, extracted_text)
print(cleaned_text)
