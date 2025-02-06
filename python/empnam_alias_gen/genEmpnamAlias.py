def generate_alias(name: str) -> str:
    if len(name) <= 20:
        return name
    return "".join(word[0].upper() for word in name.split())

# Example usage okey
print(generate_alias("Jonathan Christopher Smith"))  # Output: JCS
print(generate_alias("Short Name"))