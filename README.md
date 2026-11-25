# Lebenslauf (Typst, an Europass angelehnt)

| Datei          | Zweck                                         |
|----------------|-----------------------------------------------|
| `cv.yaml`      | **Alle Inhalte** – nur diese Datei pflegen     |
| `template.typ` | Layout (Farben, Abstände, Überschriften)       |
| `cv.typ`       | Einstiegspunkt, verbindet Daten und Layout     |

## Bauen

```bash
typst compile cv.typ
```

Live-Vorschau beim Bearbeiten:

```bash
typst watch cv.typ
```

Archivfeste Variante (PDF/A-3b, z. B. für Bewerbungsportale):

```bash
typst compile --pdf-standard a-3b cv.typ
```

## Pflege

- Datumsangaben als `"JJJJ-MM"`. Ohne `end` (oder mit `end: heute`) steht „AKTUELL“ da, bei einem Ende in der Zukunft „vsl.“.
- Einträge werden automatisch absteigend nach Startdatum sortiert.
- Leere oder fehlende Felder werden einfach nicht angezeigt.
- Foto: Bild ablegen und bei `photo:` den Dateinamen eintragen.
- Englische Version: `cv.yaml` kopieren, `lang: en` setzen und in einer Kopie von `cv.typ` die Datei einlesen.

## Maschinenlesbarkeit

- Echter Text ohne Icons, keine Silbentrennung und keine Ligaturen, damit Schlagworte beim Parsen ganz bleiben.
- Getaggtes PDF mit der Lesereihenfolge Name → Kontakt → Berufserfahrung → Bildung → Kenntnisse.
- PDF-Metadaten: Titel, Autor, Kurzprofil und die Skills als Keywords.
- `cv.yaml` ist als Anhang ins PDF eingebettet, sodass die Rohdaten strukturiert mitgeliefert werden.
