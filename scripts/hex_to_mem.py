# hex_to_mem.py
import sys

def hex_to_mem(input_file, output_file):
    with open(input_file, "r") as f_in, open(output_file, "w") as f_out:
        for line in f_in:
            if line.startswith("@"):
                continue  # Skip address lines
            # Remove whitespace and split into individual bytes
            bytes_list = line.strip().split()
            # Group bytes into 32-bit words (4 bytes per line)
            for i in range(0, len(bytes_list), 4):
                word = "".join(bytes_list[i:i+4][::-1])  # Little-endian format
                f_out.write(word + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 hex_to_mem.py <input.hex> <output.mem>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    hex_to_mem(input_file, output_file)



# hex_to_mem.py
# import sys

# input_file = sys.argv[1]
# output_file = sys.argv[2]

# with open(input_file, "r") as f_in, open(output_file, "w") as f_out:
#     for line in f_in:
#         if line.startswith("@"):
#             continue  # Skip address lines
#         f_out.write(line.strip() + "\n")