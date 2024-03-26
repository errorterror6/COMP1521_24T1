#include <stdio.h>
#include <stdint.h>

// Printer flags as #defines
// Whether the printer is out of ink
#define NO_INK (0x1)       // 0b 0000 0001
// Whether to print/scan in colour
#define COLOUR (0x2)       // 0b 0000 0010
// Select print mode
#define SELECT_PRINT (0x4) // 0b 0000 0100
// Select scan mode
#define SELECT_SCAN (0x8)  // 0b 0000 1000
// Start print/scan
#define START (0x10)       // 0b 0001 0000

// The printer
uint8_t printerControl = 0; // 0b 0000 0000

void checkInk(void);               // Question A
void replaceInk(void);             // Question B
void useColourAndSelectScan(void); // Question C
void toggleMode(void);             // Question D
void start(void);                  // Question E

// Main function for testing
int main(void)
{
    printf("printerControl = 0x%02x\n", printerControl);
    // checkInk();
    // replaceInk();
    // useColourAndSelectScan();
    // start();
    // toggleMode();
    printf("printerControl = 0x%02x\n", printerControl);
}

// Prints whether the printer has ink
void checkInk(void)
{
    if (printerContrl & NO_INK) {
        printf("Out of ink\n");
    } else {
        printf("INK OK\n");
    }


}

// Assume the user has replaced the ink
// So, we tell the printer there's ink again
void replaceInk(void)
{
    printerControl = printerControl & ~NO_INK;
    
}

// Select colour and scan mode
// Assume no mode has been selected yet
void useColourAndSelectScan(void)
{
    printerControl |= (SELECT_SCAN | COLOUR)
 
}

// Toggle between print and scan mode
// Assume a mode has already been selected
void toggleMode(void)
{


}

// Start printing/scanning and print relevant messages
void start(void)
{
    // Check that only 1 mode is selected
    // Double bang to boolean-ise our bitwise results
    int scanSelected = !!(printerControl & SELECT_SCAN);
    int printSelected = !!(printerControl & SELECT_PRINT);

    if (scanSelected == printSelected) {
        // Either both or no modes were selected
        printf("Invalid mode\n");
        return;
    }

    if (printSelected) {
        if (printerControl & NO_INK) {
            printf("Trying to print, but no ink\n");
            return;
        }

        printf(
            "Printing in %s\n",
            ((printerControl & COLOUR) ? "colour" : "black and white")
        );
    } else {
        printf(
            "Scanning in %s\n",
            ((printerControl & COLOUR) ? "colour" : "black and white")
        );

    }

    // Start the task
    printerControl |= START;

    while (printerControl & START) {
        // Infinite loop until the printer unsets the start bit
        // In our code, this will never finish because we don't have a real printer on the other side telling us when it's done
    }

    printf("Finished!\n");
}