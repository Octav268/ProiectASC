# Procesarea Binară a Șirurilor Hexazecimale

## 1. Descriere Generală
Acest program procesează un flux de date introdus de utilizator sub formă de caractere hexazecimale ASCII. Procesarea implică:

- Transformarea datelor în valori numerice pe 8 biți.
- Calcularea unui **cuvânt de control C** (16 biți) folosind sume și operații logice.
- Sortarea descrescătoare a șirului.
- Aplicarea unor rotații bit la bit în funcție de ultimii doi biți ai fiecărui octet.

Rezultatele intermediare și finale sunt afișate atât în formate **binar**, cât și **hexazecimal**.

---

## 2. Structura Programului

### 2.1. Citire și Conversie
- Programul citește datele de la utilizator și le transformă în valori numerice.
- Fiecare octet este format din două cifre hexadecimale, care sunt combinate pentru a forma valoarea finală.
- Literele mari și mici sunt tratate uniform pentru a asigura conversia corectă în valori numerice între 0 și 15.

### 2.2. Cuvântul C
- **Partea superioară**: reprezintă suma tuturor octeților. Dacă suma depășește 255, se păstrează doar cei 8 biți mai puțin semnificativi.
- **Partea inferioară**: se bazează pe analiza biților centrali ai fiecărui octet și pe o combinație între primul și ultimul element din șir.

### 2.3. Sortare și Rotiri
- Șirul este sortat descrescător.
- Fiecare octet din șirul sortat poate fi rotit pe baza valorii ultimilor doi biți:
  - Dacă ultimii biți sunt `01` sau `10` → rotire la stânga o dată.
  - Dacă ultimii biți sunt `11` → rotire la stânga de două ori.
  - Dacă ultimii biți sunt `00` → octetul rămâne nemodificat.

---

## 3. Provocări și Soluții

### 3.1. Optimizarea schimbului de valori
- **Provocare**: schimbarea valorilor în timpul sortării putea afecta performanța.
- **Soluție**: utilizarea unei metode eficiente de swap pentru a menține viteza ridicată în bucle mari.

### 3.2. Numărarea biților de 1
- **Provocare**: verificarea fiecărui bit individual era ineficientă pentru șiruri lungi.
- **Soluție**: implementarea unui algoritm care verifică doar biții de 1, reducând considerabil timpul de execuție.

### 3.3. Managementul codului și reutilizarea
- **Provocare**: codul pentru afișarea rezultatelor era redundant.
- **Soluție**: arhitectură modulară, cu funcții de bază pentru afișarea unui octet, extinse pentru afișarea șirurilor și valorilor pe 16 biți. Salvarea și restaurarea registrelor interne a prevenit conflictele în bucle.
