# your C files
C_FILES=()

# your assembly files (don't include the ones that come with this repo)
ASM_FILES=()

ASM_FILES+=(vectors.s)

for c_file in ${C_FILES[@]}; do
    # compile the .c file and add the resulting .s to the asm files
    echo cc65 --cpu 65c02 $c_file
    cc65 --cpu 65c02 $c_file
    ASM_FILES+=(${c_file%.c}.s)
done

OBJ_FILES=()
for asm_file in ${ASM_FILES[@]}; do
    # assemble the .s files and the resulting .o file to the list
    echo ca65 --cpu 65c02 $asm_file
    ca65 --cpu 65c02 $asm_file
    OBJ_FILES+=(${asm_file%.s}.o)
done

echo ld65 -C custom.cfg ${OBJ_FILES[@]} custom.lib
ld65 -C custom.cfg ${OBJ_FILES[@]} custom.lib