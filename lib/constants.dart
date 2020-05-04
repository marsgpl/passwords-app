import 'package:flutter/material.dart';

const APP_TITLE = 'Passwords';
const PRIMARY_COLOR = Colors.blue;

// try to masquerade our masterkey at user's device
const MASTERKEY_STORAGE_KEY = 'Stage2Seed';
const MASTERKEY_LENGTH = 32;
const MASTERKEY_INIT_VECTOR_STORAGE_KEY = 'SessionCookie';
const MASTERKEY_INIT_VECTOR_LENGTH = 16;
const MASTERKEY_DECOY_STORAGE_KEYS = [
    'InitSeed',
    'Stage1Seed',
    'Stage3Seed',
    'Masterkey', // honeypot
    'InitVector', // honeypot
];
