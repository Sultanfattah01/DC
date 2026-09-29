# DC — a personal professional network

A SwiftUI iPhone app. Think LinkedIn, but scoped to people you've actually met in person: everyone in your network has a place you met them, a note about what you talked about, and a feed of what they're working on.

## Open in Xcode

```bash
open DC.xcodeproj
```

Pick an iPhone simulator and press **⌘R**.

## The five tabs

**Feed** — updates from your network and from organizers of events you follow. Tap the composer to post an update, milestone, hiring note, or question. Posts show the author's role and, for people you've met, a "Met at SF Design Week" line under their name; event posts carry a badge with the event title. You can like posts, filter the feed by type, to events only, or to just your own, and open any post to read and add comments.

**Events** — browse everything happening and sign up. Each event is a card with its date, organizer, time, venue, price, how many spots are left, and which people from your network are going. Attend or save straight from the card, filter by Going, Saved, Free, category, or Past, and search by title, organizer, city, or topic. If you're attending something, a "Next up" banner sits at the top with a countdown. Tap a card for the full detail page: capacity bar, agenda, topics, the people you've met who are going, a link to the organizer's profile, and the organizer's posts about the event. Attendees can post their own updates to an event. The + button lets you host your own event, with an agenda editor and topics.

**Network** — a dashboard over the people you've collected. The gradient panel counts your connections with breakdowns for this week, favorites, and unique companies, followed by a bar chart by relationship type (lead, client, colleague, mentor, friend). Below is the full list, searchable by name, company, role, or where you met, with chip filters, swipe-to-favorite, and swipe-to-delete.

**Messages** — direct conversations with people in your network. The list shows each person's avatar, the last message, a relative timestamp, where you met them, and an unread count; the tab itself carries an unread badge. Search runs across names, companies, and message text, and you can swipe to delete a thread. The compose button opens a searchable picker of your network. Inside a thread, messages are grouped by day with Today/Yesterday separators, your messages use your card's gradient, and the person's avatar in the toolbar jumps to their profile. You can also message someone straight from their profile, where the button shows an unread count.

**Profile** — your full profile: banner, photo, headline, About, Experience with a timeline, Education, Skills, the events you're attending, your recent posts, and a strip of people you've met. Everything is editable from one place, and the **My Card** button opens your shareable business card with your avatar, contact block, tappable links, and a system share sheet.

## Profiles

Your profile and each connection's profile both support:

- About section for longer-form background
- Experience entries with title, company, location, years, and a summary (current roles are labeled "Present")
- Skills as chips
- Contact details that open Mail, Phone, and Safari directly

Your profile adds Education, a photo and banner from the system photo picker, five color themes, and unlimited custom links with icons.

Each connection adds the personal layer that makes this different from a résumé site: **where you met**, **what you talked about**, when you saved them, their relationship type, and a favorite flag.

## Project structure

```
DC/
├── DCApp.swift
├── Models/
│   ├── UserProfile.swift        # You: profile, links, themes, Color(hex:)
│   ├── Connection.swift         # People you've met
│   ├── Experience.swift         # Experience + Education entries
│   ├── Event.swift              # Events, categories, formats, agendas
│   ├── Conversation.swift       # Message threads
│   └── Post.swift               # Posts, comments, sample network data
├── ViewModels/
│   └── AppStore.swift           # Shared state, feed, metrics, persistence
├── Views/
│   ├── RootView.swift           # Tab bar
│   ├── FeedView.swift           # Feed + post composer
│   ├── PostCardView.swift       # Reusable post card
│   ├── PostDetailView.swift     # Post + comment thread
│   ├── EventsView.swift         # Event discovery + filters
│   ├── EventCardView.swift      # Reusable event card with RSVP
│   ├── EventDetailView.swift    # Agenda, attendees, organizer posts
│   ├── EventEditorView.swift    # Host / edit an event
│   ├── MessagesView.swift       # Conversation list + new message picker
│   ├── ChatView.swift           # Message thread
│   ├── ProfileView.swift        # Your full profile
│   ├── ProfileEditorView.swift  # Edit everything about you
│   ├── ProfileSections.swift    # Avatar, section card, experience, skills, flow layout
│   ├── ExperienceEditorView.swift # Shared experience + skills editors
│   ├── MyCardView.swift         # Business card + links + share
│   ├── BusinessCardView.swift   # Reusable card visual
│   ├── ConnectionsView.swift    # Network dashboard + list
│   ├── ConnectionDetailView.swift # Someone else's profile
│   └── ConnectionEditorView.swift # Add / edit a person
└── Assets.xcassets
```

State lives in a single `AppStore` and persists locally as JSON in `UserDefaults`, so your profile, network, events, posts, and messages survive restarts. The app seeds a sample network, seven events, and three conversations on first launch so nothing starts empty.

## Requirements

- Xcode 15+
- iOS 17+

## Not built yet

This is a single-device app: the "network" is local, so posts, profiles, and messages aren't shared between real users. Messages you send are stored locally and nobody replies — there's no server behind them. Turning it into a true social platform needs a backend (accounts, a real feed, push notifications, and card exchange between devices). QR code exchange for meeting someone in person would be the natural next step before that.
