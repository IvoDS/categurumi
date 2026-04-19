<?php

namespace App\Filament\Resources\Creations;

use App\Filament\Resources\Creations\Pages\CreateCreation;
use App\Filament\Resources\Creations\Pages\EditCreation;
use App\Filament\Resources\Creations\Pages\ListCreations;
use App\Filament\Resources\Creations\Schemas\CreationForm;
use App\Filament\Resources\Creations\Tables\CreationsTable;
use App\Models\Creation;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class CreationResource extends Resource
{
    protected static ?string $model = Creation::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    public static function form(Schema $schema): Schema
    {
        return CreationForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return CreationsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListCreations::route('/'),
            'create' => CreateCreation::route('/create'),
            'edit' => EditCreation::route('/{record}/edit'),
        ];
    }
}
