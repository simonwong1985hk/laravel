<?php

use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::group(['middleware' => 'auth:sanctum'], function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::withoutMiddleware(['auth:sanctum'])->group(function () {
        Route::post('/login', [AuthController::class, 'login'])
            ->name('login');

        Route::post('/register', [AuthController::class, 'register'])
            ->name('register');
    });

    Route::post('/logout', [AuthController::class, 'logout'])
        ->name('logout');
});
