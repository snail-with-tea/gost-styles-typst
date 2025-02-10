#import "@preview/codly:1.2.0": *

#import "@preview/codly-languages:0.1.6": *

#let main_styling(
  font-type: "Times New Roman",
  font-size: 14pt,
  languages: codly-languages,
  body,
) = {
  set page(
    paper: "a4",
    margin: (
      top: 1cm,
      bottom: 2cm,
      left: 2.5cm,
      right: 1cm,
    ),
    binding: left,
  )

  set text(
    font: font-type,
    lang: "ru",
    size: font-size,
    fallback: true,
    hyphenate: false,
  )

  set par(
    leading: 1em, // looks like line spacing 1.5
    first-line-indent: 2.5em,
    justify: true,
    linebreaks: "optimized",
  )

  set enum(indent: 2.5em)

  set heading(numbering: "1.", outlined: true)

  // set underline(offset: underline-offset, stroke: underline-stroke)

  show heading: self => {
    set block(
      above: 3em,
      below: 3em,
    ) // Заголовки отделяют от текста сверху и снизу тремя интервалами (ГОСТ Р 7.0.11-2011, 5.3.5)

    if self.level == 1 {
      set text(size: font-size * 1.2)
      pagebreak() // новая страница для разделов 1 уровня
      counter(figure).update(0) // сброс значения счетчика рисунков
      counter(math.equation).update(0) // сброс значения счетчика уравнений
    } else {
      set text(size: font-size)
    }
    self
  }
  /* show heading.where(level: 1): self => block(width: 100%)[
    #set text(16pt, weight: "bold")
  ] */

  // Настройка блоков кода
  show: codly-init.with()
  codly(languages: languages)

  show figure: set block(breakable: true)
  show figure.where(kind: image): set figure(supplement: [Рисунок])
  show figure.where(kind: table): set figure(supplement: [Таблица])
  show figure.where(kind: raw): set figure(supplement: [Листинг])
  show figure.where(kind: raw): set figure(
    numbering: num => ((counter(heading).get().slice(0, 1) + (num,)).map(str).join(".")),
  )

  show outline: self => {
    show heading: set align(center)
    self
  }
  set outline(indent: 1.5em, depth: 3)

  body
}

// Настройка Приложения
#let appendix(body) = {
  // Reset the title numbering.
  counter(heading).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: math.equation)).update(0)
  counter(figure.where(kind: raw)).update(0)

  // Number headings using letters.
  show heading.where(level: 1): set heading(numbering: "Приложение A. ")
  show heading.where(level: 2): set heading(numbering: "A.1 ", supplement: [Приложение])

  // Set the numbering of the figures.
  show figure.where(kind: raw): set figure(
    numbering: num => {
      let annex = counter(heading).get().first()
      [#numbering("A.", annex)#numbering("1", num)]
    },
  )

  // Set that we're in the annex
  state("section").update("annex")

  body
}

#let ulineh-stroke = 0.050em
#let ulineh-offset = 0.110em
// Underline box
#let ulineh(width, ..box_args) = context {
  let stroke = underline.stroke
  let offset = underline.offset
  if offset == auto {
    offset = ulineh-offset
  }
  if stroke == auto {
    stroke = ulineh-stroke
  }

  box(
    width: width,
    stroke: (bottom: stroke),
    outset: (bottom: offset),
    ..box_args,
  )
}

#let indent-par(self) = par[#h(2.5em)#self]

#let init-lab(
  paper-title: [
    *Журнал лабораторных работ*
  ],
  author-first-name: [Имя Отчество],
  author-last-name: [Фамилия],
  author-initials: [И.О.],
  author-group: [ВКБ24],
  author-width: 9cm,
  checked-by: (
    (
      first-name: "Имя Отчество",
      last-name: "Фамилия",
      initials: "И.О.",
      regalia: "уч. должность",
    ),
  ),
  checked-title: "Утвердил:",
  prefer-initials: false,
  body,
) = {
  let author-name = author-last-name + " " + author-first-name
  let author-short = author-last-name + " " + author-initials

  show: main_styling

  align(
    center,
    image("DonSTU_sign.png", height: 1.6cm),
  )

  align(center)[
    МИНИСТЕРСТВО НАУКИ И ВЫСШЕГО ОБРАЗОВАНИЯ \
    РОССИЙСКОЙ ФЕДЕРАЦИИ

    *ФЕДЕРАЛЬНОЕ ГОСУДАРСТВЕННОЕ БЮДЖЕТНОЕ \
    ОБРАЗОВАТЕЛЬНОЕ УЧРЕЖДЕНИЕ ВЫСШЕГО ОБРАЗОВАНИЯ \
    «ДОНСКОЙ ГОСУДАРСТВЕННЫЙ ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ» \
    (ДГТУ)*
    #v(1cm)
    Факультет: Информатика и вычислительная техника \
    Кафедра: Кибербезопасность информационных систем
    #v(2cm)
    #paper-title
  ]
  v(1fr)
  align(right)[
    #block(width: 9cm)[
      Выполнил обучающийся гр.
      #underline[#ulineh(1fr) #author-group #ulineh(1fr)]

      #underline[#ulineh(1fr) #author-name #ulineh(1fr)]
      #v(-0.7em)
      #text(size: 11pt)[#h(1fr) (Фамилия,Имя,Отчество) #h(1fr)]

      #align(left)[#context {
          if par.first-line-indent != none {
            h(-par.first-line-indent)
          }
          [#checked-title]
        }]

      #for supervizor in checked-by {
        let regalia = supervizor.at("regalia", default: "уч. должность")
        let last-name = supervizor.at("last-name", default: "Фамилия")
        let first-name = supervizor.at("first-name", default: "Имя Отчество")
        let initials = supervizor.at(
          "initials",
          default: [
            #(
              first-name
                .split()
                .map(part => {
                  [#part.first().]
                })
                .join()
            )
          ],
        )
        let full = regalia + [ ] + last-name + [ ] + first-name
        let short = regalia + [ ] + last-name + [ ] + initials
        let name = context {
          let width = measure(full).width
          if width > author-width or prefer-initials {
            short
          } else {
            full
          }
        }
        [
          #underline[#ulineh(1fr) #name #ulineh(1fr)]
          #v(-0.7em)
          #text(size: 11pt)[#h(1fr) (должность,Фамилия,Имя,Отчество) #h(1fr)]
          #parbreak()
        ]
      }
    ]
  ]
  v(1fr)
  align(center)[
    Ростов-на-Дону \
    #datetime.today().display("[year]")
  ]

  outline()
  set page(numbering: "1")
  body
}
