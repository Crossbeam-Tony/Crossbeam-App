import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);

const profiles = [
  {
    "id": "bfceac8f-c32d-44b5-8b4e-643e7dbb5478",
    "email": "brian.james@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "brian.james"
  },
  {
    "id": "0f377eeb-e20a-4c5c-a159-6e206d17b2c6",
    "email": "brandon.foster@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "brandon.foster"
  },
  {
    "id": "2cce85c3-972c-4b0c-8d13-0e649bb7881c",
    "email": "chris.davis@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "chris.davis"
  },
  {
    "id": "4e5adda1-71e6-4df0-a260-9722e85da43b",
    "email": "mike.smith@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "mike.smith"
  },
  {
    "id": "f84a5302-e7a8-48aa-b10a-822085049151",
    "email": "zach.hill@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "zach.hill"
  },
  {
    "id": "6e35caa5-0f0d-4a57-bd56-20511439ec26",
    "email": "josh.johnson@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "josh.johnson"
  },
  {
    "id": "81ef18ef-cbe9-4d5f-9254-5c30bbca9544",
    "email": "kyle.evans@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "kyle.evans"
  },
  {
    "id": "7db92f91-956e-47f1-82d2-8c91b13a0a82",
    "email": "kevin.anderson@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "kevin.anderson"
  },
  {
    "id": "83e973b7-e34e-4552-bfdd-0026656beedc",
    "email": "evan.moore@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "evan.moore"
  },
  {
    "id": "3dbfa3ee-39fc-44f6-8584-ba98e4f6fcfa",
    "email": "tony.brown@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "tony.brown"
  },
  {
    "id": "01b0b21f-9159-4d60-9112-f0ecd5e0a48e",
    "email": "derek.franklin@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "derek.franklin"
  },
  {
    "id": "400cee51-56e0-400a-8b55-84c13aff7f2c",
    "email": "aaron.irwin@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "aaron.irwin"
  },
  {
    "id": "9100f596-7787-42f8-821f-1aa06395149d",
    "email": "shawn.garcia@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "shawn.garcia"
  },
  {
    "id": "c3b9928a-2921-42d8-aa54-bbe0dfb394d2",
    "email": "dan.lewis@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "dan.lewis"
  },
  {
    "id": "d7507a27-9fe1-4259-8490-2dfd2b439082",
    "email": "cody.klein@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "cody.klein"
  },
  {
    "id": "8c3afdfe-d8df-4349-b950-ecb4a118ed09",
    "email": "frank.nelson@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "frank.nelson"
  },
  {
    "id": "3fad4b0e-ac86-4735-9492-86c7c264e99b",
    "email": "grant.owens@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "grant.owens"
  },
  {
    "id": "d3266d4d-a943-469d-8ad9-7adad5132d01",
    "email": "hank.perez@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "hank.perez"
  },
  {
    "id": "91fca670-e8b5-45b1-8c62-fb19841fe989",
    "email": "ian.quinn@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "ian.quinn"
  },
  {
    "id": "f1e586a4-d7c6-4d72-a6e0-51a6e80e537e",
    "email": "owen.vargas@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "owen.vargas"
  },
  {
    "id": "ed5a00df-0b60-4923-b883-7a50bf1cb50d",
    "email": "jake.reed@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "jake.reed"
  },
  {
    "id": "59ad51e9-cccc-4700-b0ea-3a067ce262fc",
    "email": "leo.scott@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "leo.scott"
  },
  {
    "id": "2278b3e5-7008-4f84-b949-29f5da8c8f0f",
    "email": "paul.walker@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "paul.walker"
  },
  {
    "id": "824995ce-c2dc-4c9c-a145-06b5fb10f850",
    "email": "matt.turner@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "matt.turner"
  },
  {
    "id": "d91e5942-bd9c-464f-9e6c-32f29dc2f7c9",
    "email": "nate.upton@email.com",
    "bio": "Just a local guy into cars and projects.",
    "location": "Valrico, FL",
    "username": "nate.upton"
  }
];

for (const profile of profiles) {
  const { data, error } = await supabase
    .from('profiles')
    .insert([{ id: profile.id, bio: profile.bio, location: profile.location, username: profile.username }]);

  if (error) {
    console.error(`❌ Failed to insert profile for ${profile.email}:`, error.message);
  } else {
    console.log(`✅ Inserted profile for ${profile.email}`);
  }
}
