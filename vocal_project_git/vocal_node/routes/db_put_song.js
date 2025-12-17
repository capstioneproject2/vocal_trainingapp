// 📁 routes/db_put_song.js

require('dotenv').config();

const mongoose = require('mongoose');
const Song = require('./songDB');

const MONGO_URI = process.env.MONGO_URI;

if (!MONGO_URI) {
  console.error("❌ ERROR: MONGODB_URI is not defined in .env");
  process.exit(1);
}

const HANRORO_SONG_DATA = {
  songId: "0001",
  title: "사랑하게 될 거야",
  singer: "한로로",
  wavPath: "songs/사랑하게 될 거야/hanroro.wav",
  lyricsCsvPath: "songs/사랑하게 될 거야/hanroro_lyrics.csv",
  refF0Path: "songs/사랑하게 될 거야/hanroro_pYIN_threshold.npy",
  MIDIPath: "songs/사랑하게 될 거야/사랑하게 될 거야_멜로디악보_MIDI.MIDI"
};

async function initializeDB() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('✅ MongoDB Connected!');
    console.log('📂 DB Name:', mongoose.connection.name);
    console.log('📁 Collection Name:', Song.collection.collectionName);

    const result = await Song.findOneAndUpdate(
      { songId: HANRORO_SONG_DATA.songId },
      HANRORO_SONG_DATA,
      { upsert: true, new: true }
    );

    console.log(`🎉 Song Data initialized/updated: ${result.title} (${result.songId})`);

  } catch (err) {
    console.error('❌ DB Initialization Failed:', err);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 MongoDB connection closed');
  }
}

initializeDB();
