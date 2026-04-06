This specification is designed to provide an AI coding agent with the precise parameters, logic, and experimental structure required to replicate the "number change detection" paradigm described in the study by Decarli, Piazza, and Izard[cite: 1, 7].

## 1. Stimuli and Physical Layout
The experiment involves two concurrent streams of images displayed on a single large projection screen[cite: 130, 178].

* **Display Specifications:**
    * **Background:** Solid white[cite: 131].
    * **Dots:** Solid black[cite: 131].
    * **Image Dimensions:** $68 \times 51$ cm per stream[cite: 131].
    * **Gap:** 43 cm between the two streams[cite: 131].
* **Visual Timing:**
    * **Stimulus Duration:** 500 ms[cite: 132, 145].
    * **Inter-Stimulus Interval (Blank Screen):** 300 ms[cite: 132, 145].
* **Numerosities:** The target numerosities are **5** and **20** (a 1:4 ratio)[cite: 133, 134, 135, 247].


---

## 2. Non-Numerical Parameter Controls
To ensure infants respond to numerosity rather than physical area or dot size, the stimuli must be generated under two control conditions[cite: 147, 148, 149]:

### Extensive Parameters Equated
Total area and convex hull are roughly equal between 5 and 20 dots[cite: 149, 150].
* **5 dots:** 2.7–4.6 cm diameter per dot; array occupies a 20–45 cm diameter circular area[cite: 150].
* **20 dots:** 1.3–2.3 cm diameter per dot; array occupies the same 20–45 cm diameter circular area[cite: 150].

### Intensive Parameters Equated
Dot size and density are roughly equal between 5 and 20 dots[cite: 149, 151].
* **5 dots:** 2.3–4.6 cm diameter per dot; array occupies a 15–25 cm diameter circular area[cite: 151].
* **20 dots:** 2.3–4.6 cm diameter per dot; array occupies a larger 25–50 cm diameter circular area[cite: 151].

---

## 3. Sequence Logic and Streams
Each stream consists of a sequence of **24 images**, repeated **twice** (total of 48 images, ~40 seconds duration)[cite: 136].

* **Constant Stream:** All 48 images show the same numerosity (either all 5s or all 20s)[cite: 133].
* **Alternating Stream:** Images systematically alternate between 5 and 20 dots (e.g., 5-20-5-20...)[cite: 134].
* **Random Stream:** Images of 5 and 20 dots are mixed in an unpredictable order, ensuring exactly 12 of each per 24-image block[cite: 135].

---

## 4. Experimental Paradigm (Trial Structure)
The experiment consists of **4 trials** per participant[cite: 155].

1.  **Trial Initiation:** Each trial begins with a "looming attractor image" at the center of the screen to focus the infant's attention[cite: 154, 159].
2.  **Stream Presentation:** Once the infant looks at the screen, the two streams (left and right) begin simultaneously[cite: 154].
3.  **Counterbalancing:**
    * The side (left vs. right) of the changing stream must alternate across the 4 trials[cite: 155].
    * The parameter control (extensive vs. intensive) must be used in pairs (e.g., Trials 1–2 use intensive-equated; Trials 3–4 use extensive-equated)[cite: 156].
    * The specific numerosity used in the constant stream (5 or 20) should be counterbalanced across participants[cite: 157].

---

## 5. Specific Experiment Conditions
The coding agent should implement three distinct experimental configurations based on the study's three experiments[cite: 160]:

| Experiment | Left/Right Stream Pairs | Purpose |
| :--- | :--- | :--- |
| **Preliminary** | **Alternating** vs. **Constant** | Establish baseline preference for change[cite: 177, 179]. |
| **Experiment 1** | **Random** vs. **Constant** | Test if changes alone (no pattern) drive interest[cite: 198, 204]. |
| **Experiment 2** | **Alternating** vs. **Random** | Test if the alternating pattern adds extra appeal[cite: 207, 234]. |

---

## 6. Data Collection Requirements
The code must facilitate recording of **looking times** toward the left and right sides of the screen for each trial[cite: 161, 169]. To replicate the analysis, the system should compute the **log ratio** of accumulated looking times across all trials[cite: 170, 171].
:wq
