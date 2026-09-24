// Mock data — structured to mirror future Supabase tables (profiles, chats, messages, groups)

export interface Profile {
  id: string;
  first_name: string;
  last_name: string;
  university: string;
  major?: string;
  year?: string;
  avatar_url: string;
  bio?: string;
  interests?: string[];
}

export interface Chat {
  id: string;
  participant: Profile;
  last_message: string;
  last_message_at: string;
  unread_count: number;
  online?: boolean;
}

export interface Message {
  id: string;
  chat_id: string;
  sender_id: string;
  body: string;
  created_at: string;
}

export interface Group {
  id: string;
  name: string;
  description: string;
  member_count: number;
  category: "classmates" | "members";
  color: string;
}

const avatar = (seed: string) =>
  `https://api.dicebear.com/7.x/avataaars/svg?seed=${seed}&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf`;

export const currentUser: Profile = {
  id: "me",
  first_name: "Alex",
  last_name: "Morgan",
  university: "Stanford University",
  major: "Computer Science",
  year: "Junior",
  avatar_url: avatar("Alex"),
  bio: "CS junior passionate about AI, design, and building things that matter.",
  interests: ["AI/ML", "Design", "Startups", "Photography"],
};

export const chats: Chat[] = [
  {
    id: "c1",
    participant: { id: "u1", first_name: "Emma", last_name: "Wilson", university: "Stanford University", avatar_url: avatar("Emma") },
    last_message: "Are you joining the study group tonight?",
    last_message_at: "2m",
    unread_count: 2,
    online: true,
  },
  {
    id: "c2",
    participant: { id: "u2", first_name: "James", last_name: "Chen", university: "Stanford University", avatar_url: avatar("James") },
    last_message: "Thanks for the notes! Lifesaver 🙏",
    last_message_at: "1h",
    unread_count: 0,
    online: true,
  },
  {
    id: "c3",
    participant: { id: "u3", first_name: "Sofia", last_name: "Rodriguez", university: "Stanford University", avatar_url: avatar("Sofia") },
    last_message: "See you at the library at 4?",
    last_message_at: "3h",
    unread_count: 1,
  },
  {
    id: "c4",
    participant: { id: "u4", first_name: "Marcus", last_name: "Johnson", university: "Stanford University", avatar_url: avatar("Marcus") },
    last_message: "Just submitted the assignment 🎉",
    last_message_at: "Yesterday",
    unread_count: 0,
  },
  {
    id: "c5",
    participant: { id: "u5", first_name: "Priya", last_name: "Patel", university: "Stanford University", avatar_url: avatar("Priya") },
    last_message: "Can you share the lecture slides?",
    last_message_at: "2d",
    unread_count: 0,
  },
  {
    id: "c6",
    participant: { id: "u6", first_name: "Liam", last_name: "Anderson", university: "Stanford University", avatar_url: avatar("Liam") },
    last_message: "Lab partners for next week?",
    last_message_at: "3d",
    unread_count: 0,
  },
];

export const messagesByChat: Record<string, Message[]> = {
  c1: [
    { id: "m1", chat_id: "c1", sender_id: "u1", body: "Hey! How was the lecture today?", created_at: "10:14" },
    { id: "m2", chat_id: "c1", sender_id: "me", body: "Pretty intense, the new chapter is dense 😅", created_at: "10:16" },
    { id: "m3", chat_id: "c1", sender_id: "u1", body: "Same here. Want to study together?", created_at: "10:17" },
    { id: "m4", chat_id: "c1", sender_id: "me", body: "Absolutely. Library at 4?", created_at: "10:18" },
    { id: "m5", chat_id: "c1", sender_id: "u1", body: "Are you joining the study group tonight?", created_at: "10:42" },
  ],
  c2: [
    { id: "m1", chat_id: "c2", sender_id: "me", body: "Sent you the notes from today", created_at: "09:02" },
    { id: "m2", chat_id: "c2", sender_id: "u2", body: "Thanks for the notes! Lifesaver 🙏", created_at: "09:30" },
  ],
};

export const groups: Group[] = [
  { id: "g1", name: "CS 161 — Algorithms", description: "Spring 2025 cohort", member_count: 84, category: "classmates", color: "from-blue-400 to-blue-600" },
  { id: "g2", name: "CS 229 — Machine Learning", description: "Lectures, problem sets & projects", member_count: 142, category: "classmates", color: "from-sky-400 to-blue-500" },
  { id: "g3", name: "Design Studio", description: "UI/UX enthusiasts", member_count: 56, category: "classmates", color: "from-cyan-400 to-blue-500" },
  { id: "g4", name: "Stanford AI Society", description: "Weekly talks & hackathons", member_count: 312, category: "members", color: "from-blue-500 to-indigo-500" },
  { id: "g5", name: "Photography Club", description: "Capture campus life", member_count: 98, category: "members", color: "from-sky-500 to-blue-600" },
  { id: "g6", name: "Founders Network", description: "Student entrepreneurs", member_count: 67, category: "members", color: "from-blue-400 to-sky-500" },
];

export const suggested: Profile[] = [
  { id: "s1", first_name: "Olivia", last_name: "Bennett", university: "Stanford University", major: "Computer Science", year: "Junior", avatar_url: avatar("Olivia"), bio: "Building tools for student life. Coffee enthusiast.", interests: ["AI/ML", "Startups", "Design"] },
  { id: "s2", first_name: "Daniel", last_name: "Kim", university: "Stanford University", major: "Symbolic Systems", year: "Senior", avatar_url: avatar("Daniel"), bio: "Researching human-AI interaction.", interests: ["AI/ML", "Photography", "Music"] },
  { id: "s3", first_name: "Aisha", last_name: "Nguyen", university: "Stanford University", major: "Design", year: "Sophomore", avatar_url: avatar("Aisha"), bio: "Product designer + illustrator.", interests: ["Design", "Photography", "Art"] },
  { id: "s4", first_name: "Ethan", last_name: "Garcia", university: "Stanford University", major: "Electrical Engineering", year: "Junior", avatar_url: avatar("Ethan"), bio: "Robotics, rockets, and ramen.", interests: ["Robotics", "Startups", "AI/ML"] },
];
