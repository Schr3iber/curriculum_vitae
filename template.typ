// Europass-angelehntes Lebenslauf-Layout.
// Inhalte stehen in cv.yaml – hier nur Gestaltung.

#let accent = rgb("#204493")   // Europass-Blau
#let ink = rgb("#3a3a3a")
#let muted = rgb("#6b6b6b")
#let sidebar-fill = rgb("#f9f9f9")
#let sidebar-width = 68mm
#let margin = 12mm
#let sidebar-pad = 7mm

// Zeitstrahl
#let line-width = 1.6pt
#let dot-radius = 3.6pt
#let line-gap = 7mm            // Abstand Linie -> Text

#let labels = (
  de: (
    cv: "Lebenslauf", contact: "Kontakt", born: "Geburtsdatum", nationality: "Staatsangehörigkeit",
    address: "Adresse", phone: "Telefon", email: "E-Mail",
    experience: "Berufserfahrung", education: "Allgemeine und berufliche Bildung",
    skills: "Digitale Kompetenzen", languages: "Sprachkenntnisse",
    mother: "Muttersprache", other: "Weitere Sprachen",
    licences: "Lizenzen", profile: "Profil", today: "aktuell", expected: "vsl.",
  ),
  en: (
    cv: "Curriculum Vitae", contact: "Contact", born: "Date of birth", nationality: "Nationality",
    address: "Address", phone: "Phone", email: "Email",
    experience: "Work experience", education: "Education and training",
    skills: "Digital skills", languages: "Language skills",
    mother: "Mother tongue", other: "Other languages",
    licences: "Licences", profile: "Profile", today: "current", expected: "exp.",
  ),
)

// "2024-09" -> datetime
#let parse-date(s) = {
  let p = str(s).split("-").map(int)
  let month = p.at(1, default: 1)
  assert(month >= 1 and month <= 12, message: "Ungültiger Monat in Datum \"" + str(s) + "\" (erwartet JJJJ-MM)")
  datetime(year: p.at(0), month: month, day: 1)
}

// Offenes Ende: Feld fehlt oder heute/aktuell/now/present
#let is-open(end) = end == none or lower(str(end)) in ("heute", "aktuell", "now", "present", "current")

#let fmt-date(s) = parse-date(s).display("[month]/[year]")

#let fmt-range(start, end, l) = {
  let to = if is-open(end) { upper(l.today) } else {
    let prefix = if parse-date(end) > datetime.today() { l.expected + " " } else { "" }
    prefix + fmt-date(end)
  }
  fmt-date(start) + " – " + to
}

#let has(d, key) = key in d and d.at(key) not in (none, "", ())

// ---------- Bausteine ----------

#let section(title, body) = {
  heading(level: 2, text(size: 12pt, weight: "medium", fill: ink, tracking: 0.04em, upper(title)))
  body
}

// Abschnitt mit durchgehendem Zeitstrahl links.
#let timeline(body) = block(
  width: 100%,
  inset: (left: line-gap, bottom: 1mm),
  stroke: (left: line-width + accent),
  body,
)

// Punkt, exakt mittig auf der Linie und mittig zur Titelzeile.
// Wird als erstes Element in die Titelzeile gesetzt.
#let dot = box(width: 0pt, place(
  dx: -line-gap - dot-radius,
  dy: -0.36em - dot-radius,   // 0.36em ≈ halbe Versalhöhe über der Grundlinie
  circle(radius: dot-radius, fill: accent, stroke: none),
))

#let entry(e, l) = block(breakable: false, spacing: 4.2mm, {
  set par(spacing: 0mm)
  // Zeitraum · Ort
  text(size: 9pt, fill: accent)[
    #text(weight: "bold", fmt-range(e.start, e.at("end", default: none), l))#if has(e, "location") [ #h(1mm)·#h(1mm) #e.location]
  ]
  // Titel (mit Punkt auf dem Zeitstrahl)
  block(above: 1.8mm, below: 0mm, heading(level: 3, text(size: 11pt, weight: "bold", fill: ink)[#dot#e.title]))
  // Arbeitgeber / Einrichtung
  if has(e, "org") {
    block(above: 1.2mm, below: 0mm, text(size: 10pt, fill: muted, e.org))
  }
  if has(e, "bullets") {
    block(above: 2mm, below: 0mm, list(..e.bullets.map(b => [#b])))
  }
})

#let kv(key, value) = block(spacing: 2.5mm)[#text(weight: "bold", key + ":") #value]

// Kontakt: Bezeichnung über dem Wert (lange Adressen/E-Mails brechen sauber)
#let kv-stacked(key, value) = block(spacing: 3.2mm)[#text(size: 8.5pt, fill: muted, key) \ #value]

#let table-rows(pairs) = grid(
  columns: (34mm, 1fr),
  column-gutter: 3mm,
  row-gutter: 1.5mm,
  align: horizon,
  ..pairs.map(((k, v)) => (text(weight: "bold", fill: accent, k + ":"), v)).flatten(),
)

#let tags(items) = items.join(", ")

// ---------- Dokument ----------

#let cv(data, data-file: none) = {
  let lang = data.at("lang", default: "de")
  let l = labels.at(lang)
  let p = data.person
  let full-name = p.first_name + " " + p.last_name

  set document(
    title: l.cv + " – " + full-name,
    author: full-name,
    description: data.at("summary", default: none),
    keywords: data.at("skills", default: ()).map(s => s.items).flatten(),
  )

  // Maschinenlesbarkeit: keine Silbentrennung, keine Ligaturen,
  // echter Text statt Icons, Rohdaten als PDF-Anhang.
  set text(
    font: ("Helvetica Neue", "Helvetica", "Arial"),
    size: 10pt,
    lang: lang,
    hyphenate: false,
    ligatures: false,
    fill: ink,
  )
  set par(justify: false, leading: 0.55em, spacing: 0.8em)
  set list(marker: text(fill: accent, [•]), indent: 0mm, body-indent: 2mm, spacing: 1.3mm)
  show heading: set block(above: 0mm, below: 0mm)
  show heading.where(level: 2): set block(above: 6mm, below: 3mm)

  set page(
    paper: "a4",
    margin: (left: sidebar-pad, right: margin, y: margin),
    background: place(left + top, rect(width: sidebar-width, height: 100%, fill: sidebar-fill)),
  )

  if data-file != none {
    pdf.attach(
      data-file,
      relationship: "data",
      mime-type: "application/yaml",
      description: "Lebenslauf als strukturierte Daten",
    )
  }

  // ---- Seitenleiste
  let sidebar = {
    set align(left)
    if has(p, "photo") {
      align(center, box(clip: true, radius: 50%, width: 38mm, height: 38mm,
        stroke: 2pt + rgb("#d0d0d0"),
        image(p.photo, width: 100%, height: 100%, fit: "cover", alt: "Foto " + full-name)))
      v(4mm)
    }
    align(center, heading(level: 1, text(size: 16pt, weight: "bold", fill: ink, full-name)))
    if has(p, "headline") {
      v(1.5mm)
      align(center, text(fill: accent, p.headline))
    }
    v(5mm)
    if has(p, "birthdate") { kv-stacked(l.born, str(p.birthdate)) }
    if has(p, "nationality") { kv-stacked(l.nationality, p.nationality) }

    heading(level: 2, text(size: 12pt, weight: "medium", fill: ink, tracking: 0.04em, upper(l.contact)))
    if has(p, "address") {
      let addr = if type(p.address) == array { p.address } else { (p.address,) }
      kv-stacked(l.address, addr.join(linebreak()))
    }
    if has(p, "phone") { kv-stacked(l.phone, link("tel:" + p.phone.replace(" ", ""), p.phone)) }
    if has(p, "email") { kv-stacked(l.email, link("mailto:" + p.email, p.email)) }
    if has(p, "links") {
      for lk in p.links { kv-stacked(lk.label, link(lk.url, lk.url.replace(regex("^https?://(www\.)?"), "").trim("/", at: end))) }
    }

    if has(data, "summary") {
      heading(level: 2, text(size: 12pt, weight: "medium", fill: ink, tracking: 0.04em, upper(l.profile)))
      text(fill: muted, data.summary)
    }
  }

  // ---- Hauptteil
  let sorted(list) = list.sorted(key: e => parse-date(e.start)).rev()
  let main = {
    show heading.where(level: 2): set block(above: 5.5mm)
    if has(data, "experience") {
      section(l.experience, timeline(for e in sorted(data.experience) { entry(e, l) }))
    }
    if has(data, "education") {
      section(l.education, timeline(for e in sorted(data.education) { entry(e, l) }))
    }
    if has(data, "languages") {
      let mother = data.languages.filter(x => x.at("level", default: "") in ("Muttersprache", "Mother tongue"))
      let other = data.languages.filter(x => x not in mother)
      section(l.languages, table-rows(
        (if mother != () { ((l.mother, tags(mother.map(x => x.name))),) } else { () })
        + other.map(x => (x.name, tags((x.level,))))
      ))
    }
    if has(data, "skills") {
      section(l.skills, table-rows(data.skills.map(s => (s.category, tags(s.items)))))
    }
    if has(data, "licences") {
      section(l.licences, table-rows(data.licences.map(x => (x.name, str(x.value)))))
    }
  }

  grid(
    columns: (sidebar-width - 2 * sidebar-pad, 1fr),
    column-gutter: sidebar-pad + 8mm,
    sidebar,
    main,
  )
}
